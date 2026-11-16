// The gateway-identity area: the engine-managed binding root of the
// hosting-native CI credential chain. Every gateway lane of the organization
// — a governed repository workflow that needs exactly one cloud-side
// credential — is bound here as declared infrastructure: the estate's
// workload identity pool, one GitHub OIDC provider per lane with the
// repository-and-environment subject claim condition, the lane's federated
// service account with its federation binding, the lane's tenant-scoped
// secret container with its single-secret accessor binding, and the
// hosting-platform side of the same contract (the protected environment and
// the three variables the lane's workflow resolves). The declaration chain of
// the credential convention binds this surface: the resources are declared
// here, the concrete names, conditions, roles and labels arrive as reviewed
// instance values, and the live state is proven by the governed window's plan
// gate, read-backs and zero-drift proof — never hand-provisioned outside the
// declaration.
//
// The execution contract of this root is part of the declaration (the DPI-33
// and DPI-38 precedents): the credential host project and the GitHub
// organization target are declared instance-bound variables, so a lane
// identity that can reach more than one project or organization can never
// silently retarget this binding — a missing or malformed target fails closed
// at plan time. Credentials themselves stay outside the declaration: the
// secret payload never enters this repository, the engine state, a plan
// artifact or a log, and the applying lane authenticates through the pinned
// providers' own token channels.

provider "google" {
  project = var.gateway_project
}

provider "github" {
  owner = var.organization
}

// The estate's single workload identity pool: the trust boundary every lane
// provider federates into. Its destruction would orphan every lane provider
// and every federation binding of the estate silently while the live
// identities survive, so the provider-native deletion policy is pinned to
// PREVENT and a retirement runs through the explicit abandon path.
resource "google_iam_workload_identity_pool" "gateway" {
  project                   = var.gateway_project
  workload_identity_pool_id = var.pool_id

  display_name = var.pool_id
  description  = "Workload identity pool of the gateway lanes bound by the developer platform gateway-identity root: every lane provider of this organization federates into exactly this pool."

  deletion_policy = "PREVENT"
}

// One GitHub OIDC provider per lane. The attribute mapping projects the
// platform token subject claims the lane contract binds on; the attribute
// condition is the fail-closed subject-claim binding of the credential
// convention — the exact repository, the owning organization and the
// protected environment — so a run from a fork, a foreign repository, a
// foreign organization or an unbound environment never satisfies the
// exchange. The issuer is the hosting platform's token authority; no key
// material is declared here. The soft-delete form of a provider makes its
// identifier unreusable for roughly thirty days, so the destruction of a
// binding surface is a deliberate abandon act, never an accident: PREVENT.
resource "google_iam_workload_identity_pool_provider" "gateway" {
  for_each = var.lanes

  project                            = var.gateway_project
  workload_identity_pool_id          = google_iam_workload_identity_pool.gateway.workload_identity_pool_id
  workload_identity_pool_provider_id = each.value.provider_id

  display_name = each.value.provider_id
  description  = "GitHub OIDC provider of the ${each.key} gateway lane, bound to the repository ${each.value.repository} and the protected environment ${each.value.environment}."

  attribute_mapping = {
    "google.subject"        = "assertion.sub"
    "attribute.actor"       = "assertion.actor"
    "attribute.repository"  = "assertion.repository"
    "attribute.ref"         = "assertion.ref"
    "attribute.environment" = "assertion.environment"
  }

  attribute_condition = "assertion.repository_owner == \"${var.organization}\" && assertion.repository == \"${each.value.repository}\" && assertion.environment == \"${each.value.environment}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  deletion_policy = "PREVENT"

  depends_on = [google_iam_workload_identity_pool.gateway]
}

// The lane's federated workload identity: the short-lived principal the OIDC
// exchange resolves to. It carries no downloadable key — the platform's key
// class is structurally absent from this declaration, which is the
// no-service-account-key law expressed as infrastructure. Its destruction
// would break every binding of the lane at once, so PREVENT.
resource "google_service_account" "gateway_lane" {
  for_each = var.lanes

  project      = var.gateway_project
  account_id   = each.value.service_account_id
  display_name = each.value.service_account_id
  description  = "Federated workload identity of the ${each.key} gateway lane: assumed exclusively through the lane's workload identity provider, never through an exported key."

  deletion_policy = "PREVENT"
}

// The federation binding: which external identities may assume the lane's
// service account. The principal set is derived from the pool's own resource
// name (the platform-addressed project-number form the identifier grammar
// requires) and the lane's declared repository attribute, so the binding
// scope equals the provider condition and never a wildcard.
resource "google_service_account_iam_member" "gateway_federation" {
  for_each = var.lanes

  service_account_id = google_service_account.gateway_lane[each.key].name
  role               = each.value.federation_role
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gateway.name}/attribute.repository/${each.value.repository}"
}

// The lane's tenant-scoped secret container. This root declares the
// container, its labels and its encryption form; the secret payload is never
// part of the declaration, the state or a plan artifact. The automatic
// replication form is the platform default; a lane secret protected by a
// customer-managed key carries the key reference as a reviewed instance value
// together with the service-agent authorization below.
resource "google_secret_manager_secret" "gateway_lane" {
  for_each = var.lanes

  project   = var.gateway_project
  secret_id = each.value.secret_id

  labels = each.value.secret_labels

  replication {
    auto {
      dynamic "customer_managed_encryption" {
        for_each = each.value.secret_cmek_key_name == null ? [] : [each.value.secret_cmek_key_name]
        content {
          kms_key_name = customer_managed_encryption.value
        }
      }
    }
  }

  deletion_policy = "PREVENT"
}

// The key authorization of the platform's secret-manager service agent for a
// customer-managed lane secret: without it the secret's encryption form is
// declared but unusable. The role and the fully formed service-agent member
// arrive as reviewed instance values because the member carries the
// credential host's project number — an organization coordinate the core
// never presets.
resource "google_kms_crypto_key_iam_member" "gateway_secret_cmek" {
  for_each = {
    for lane_key, lane in var.lanes : lane_key => lane
    if lane.secret_cmek_key_name != null
  }

  crypto_key_id = each.value.secret_cmek_key_name
  role          = each.value.key_authorizer_role
  member        = each.value.key_authorizer_member
}

// The single-secret accessor binding: the lane's service account may read
// exactly its own secret and nothing else. The binding is resource-sharp on
// the lane's own secret — never a project-wide grant, never a list permission
// — which is the least-privilege law of the credential convention expressed
// as infrastructure.
resource "google_secret_manager_secret_iam_member" "gateway_lane_access" {
  for_each = var.lanes

  project   = var.gateway_project
  secret_id = google_secret_manager_secret.gateway_lane[each.key].secret_id
  role      = each.value.accessor_role
  member    = google_service_account.gateway_lane[each.key].member

  depends_on = [google_kms_crypto_key_iam_member.gateway_secret_cmek]
}

// The hosting-platform side of the same lane contract: the protected
// environment the lane's job declares. The environment's protection posture
// arrives from the instance values, so the protection is a reviewed
// declaration instead of console state; an environment without a protection
// posture is the documented unbound form and never a silent default.
resource "github_repository_environment" "gateway_lane" {
  for_each = var.lanes

  repository  = split("/", each.value.repository)[1]
  environment = each.value.environment

  can_admins_bypass   = each.value.can_admins_bypass
  prevent_self_review = each.value.prevent_self_review
  wait_timer          = each.value.wait_timer

  dynamic "reviewers" {
    for_each = length(each.value.reviewer_user_ids) > 0 ? [each.value.reviewer_user_ids] : []
    content {
      users = reviewers.value
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = each.value.protected_branches_only == null ? [] : [each.value.protected_branches_only]
    content {
      protected_branches     = deployment_branch_policy.value
      custom_branch_policies = false
    }
  }
}

// The lane contract the workflow resolves: the federation provider reference,
// the service-account identity and the credential host project, projected as
// environment variables of the lane's protected environment. Every value is
// derived from the declared resources above, never restated as a literal, so
// the workflow surface and the cloud surface cannot drift apart. These are
// non-secret coordinates: the credential itself is resolved by the lane
// through the federation at run time and never stored here.
resource "github_actions_environment_variable" "gateway_wif_provider" {
  for_each = var.lanes

  repository    = split("/", each.value.repository)[1]
  environment   = github_repository_environment.gateway_lane[each.key].environment
  variable_name = each.value.variable_names.wif_provider
  value         = google_iam_workload_identity_pool_provider.gateway[each.key].name
}

resource "github_actions_environment_variable" "gateway_service_account" {
  for_each = var.lanes

  repository    = split("/", each.value.repository)[1]
  environment   = github_repository_environment.gateway_lane[each.key].environment
  variable_name = each.value.variable_names.service_account
  value         = google_service_account.gateway_lane[each.key].email
}

resource "github_actions_environment_variable" "gateway_project_id" {
  for_each = var.lanes

  repository    = split("/", each.value.repository)[1]
  environment   = github_repository_environment.gateway_lane[each.key].environment
  variable_name = each.value.variable_names.project_id
  value         = var.gateway_project
}
