// Input variables of the gateway-identity area: the foundation state-home
// consumption values, the declared execution-contract targets, and the lane
// bindings of the hosting-native CI credential chain. The organization
// instance supplies every concrete value as reviewed configuration; the core
// never presets one.

variable "state_bucket_name" {
  description = "Instance-bound name of the foundation state-home bucket this root consumes as its state backend (provisioned by the state-home area's governed birth path). The organization instance supplies this value as reviewed configuration; the core never presets one."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$", var.state_bucket_name)) && !can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$", var.state_bucket_name)) && !startswith(var.state_bucket_name, "goog") && !can(regex("google", var.state_bucket_name))
    error_message = "state_bucket_name must satisfy the Cloud Storage bucket naming rules: 3-63 characters of lowercase letters, digits, hyphens, underscores and dots, alphanumeric edges, never an IP form, never the goog prefix and never google or similar spellings."
  }
}

variable "state_encryption_key" {
  description = "Instance-bound GCP KMS key reference of the client-side state and plan encryption engine layer (projects/*/locations/*/keyRings/*/cryptoKeys/*). The organization instance supplies this value as reviewed configuration; the core never presets one."
  type        = string

  validation {
    condition     = can(regex("^projects/[^/]+/locations/[^/]+/keyRings/[^/]+/cryptoKeys/[^/]+$", var.state_encryption_key))
    error_message = "state_encryption_key must be a full GCP KMS key resource name."
  }
}

variable "organization" {
  description = "Instance-bound GitHub organization login: the owner target of the hosting-platform side of this root (the DPI-38 precedent — the pinned provider's forward-compatible owner argument) and the expected repository prefix of every lane binding, so a lane identity that can reach more than one organization can never silently retarget this binding."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9]([A-Za-z0-9-]{0,37}[A-Za-z0-9])?$", var.organization)) && !can(regex("--", var.organization))
    error_message = "organization must be a valid GitHub organization login: 1-39 characters of alphanumeric characters and single hyphens, beginning and ending alphanumeric, never consecutive hyphens."
  }
}

variable "gateway_project" {
  description = "Instance-bound Google Cloud project hosting the workload identity pool, the federated service accounts and the tenant gateway secrets (the credential host of the hosting-native path). The organization instance supplies this value as reviewed configuration; the core never presets one."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.gateway_project))
    error_message = "gateway_project must be a valid Google Cloud project identifier: 6-30 lowercase letters, digits and hyphens, beginning with a letter and ending alphanumeric."
  }
}

variable "pool_id" {
  description = "Instance-bound identifier of the estate's workload identity pool (the hosting-native credential convention's one pool per platform instance): the pool is the trust boundary every lane provider federates into. The organization instance supplies this value as reviewed configuration; the core never presets one."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{4,32}$", var.pool_id)) && !startswith(var.pool_id, "gcp-")
    error_message = "pool_id must satisfy the documented pool identifier grammar: 4-32 characters of lowercase letters, digits and hyphens; the gcp- prefix is reserved by the platform and may not be used."
  }
}

variable "channel" {
  description = "Instance-bound identity of the gateway channel: the machine identity of the infrastructure-apply class that converges this root (the capability-class law of the hosting-platform machine-identity classification convention). The birth of the app itself stays a human-gated act outside the declaration - the pinned provider carries no app-birth resource and the class law never delegates a root-of-trust birth; what is declared here is the channel identity and its organization installation coordinate, so the plan gate proves the binding instead of a console state. The organization instance supplies both values as reviewed configuration; the core never presets one."
  type = object({
    app_slug        = string
    installation_id = string
  })
  nullable = false

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.channel.app_slug))
    error_message = "channel.app_slug must be the URL-friendly GitHub App slug of the declared channel identity: lowercase letters, digits and single hyphens, beginning and ending alphanumeric."
  }

  validation {
    condition     = can(regex("^[0-9]+$", var.channel.installation_id))
    error_message = "channel.installation_id must be the numeric GitHub App installation identifier of the organization installation: an empty or non-numeric value names no installation and would silently bind nothing."
  }
}

variable "lanes" {
  description = "The gateway lane bindings of the organization: one entry per consuming repository lane, keyed by the lane identity. Every entry carries the GitHub repository and protected environment of the lane, the provider and service-account identifiers of its federation, the tenant-scoped secret it may read, the two instance-bound role references (the federation role on the service account and the accessor role on its secret), the variable-name contract the lane's workflow reads, and the optional environment-projection values. A lane whose secret carries a customer-managed encryption key additionally carries the key-authorizer role and the platform's secret-manager service-agent member for the credential host project. Every concrete value arrives from the organization instance bindings; the module never carries one."
  type = map(object({
    repository            = string
    environment           = string
    provider_id           = string
    service_account_id    = string
    secret_id             = string
    federation_role       = string
    accessor_role         = string
    secret_labels         = optional(map(string), {})
    secret_cmek_key_name  = optional(string)
    key_authorizer_role   = optional(string)
    key_authorizer_member = optional(string)
    variable_names = object({
      wif_provider    = string
      service_account = string
      project_id      = string
    })
    can_admins_bypass       = optional(bool)
    prevent_self_review     = optional(bool)
    wait_timer              = optional(number)
    reviewer_user_ids       = optional(list(number), [])
    protected_branches_only = optional(bool)
  }))
  nullable = false

  validation {
    condition     = length(var.lanes) > 0
    error_message = "lanes must carry at least one gateway lane binding; an empty lane set declares a root with no purpose."
  }

  validation {
    condition     = alltrue([for lane in var.lanes : can(regex("^[a-z0-9-]{4,32}$", lane.provider_id)) && !startswith(lane.provider_id, "gcp-")])
    error_message = "Every lane provider_id must satisfy the documented provider identifier grammar: 4-32 characters of lowercase letters, digits and hyphens, never the reserved gcp- prefix."
  }

  validation {
    condition     = alltrue([for lane in var.lanes : can(regex("^[a-z]([-a-z0-9]*[a-z0-9])$", lane.service_account_id)) && length(lane.service_account_id) >= 6 && length(lane.service_account_id) <= 30])
    error_message = "Every lane service_account_id must satisfy the documented service-account account-id grammar: 6-30 characters, a leading lowercase letter, lowercase letters, digits and hyphens, ending alphanumeric."
  }

  validation {
    condition     = alltrue([for lane in var.lanes : length(lane.secret_id) > 0 && length(lane.secret_id) <= 255 && !can(regex("[ /]", lane.secret_id))])
    error_message = "Every lane secret_id must be a non-empty secret identifier of at most 255 characters carrying no path or whitespace character; the tenant-scoped naming law additionally binds the AI_GATEWAY_<TENANT_SLUG> shape on the instance side."
  }

  validation {
    condition     = alltrue([for lane in var.lanes : can(regex("^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$", lane.repository))])
    error_message = "Every lane repository must be the owner-qualified GitHub repository form the platform token subject carries: <organization>/<repository>."
  }

  validation {
    condition     = alltrue([for lane in var.lanes : startswith(lane.repository, "${var.organization}/")])
    error_message = "Every lane repository must live in the declared organization: the federation condition and the repository prefix are one contract, and a lane of a foreign organization would silently widen this root's trust boundary."
  }

  validation {
    condition     = alltrue([for lane in var.lanes : length(lane.environment) > 0 && !can(regex(":", lane.environment))])
    error_message = "Every lane environment must be a non-empty protected environment name; a colon is rejected because the pinned provider's import identifier for the environment surfaces is colon-delimited and a colon-carrying name would need escaping outside the declaration."
  }

  validation {
    condition     = alltrue([for lane in var.lanes : can(regex("^(roles|organizations/[0-9]+/roles|projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/roles)/[a-zA-Z0-9._-]+$", lane.federation_role)) && can(regex("^(roles|organizations/[0-9]+/roles|projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/roles)/[a-zA-Z0-9._-]+$", lane.accessor_role))])
    error_message = "Every lane federation_role and accessor_role must be a fully formed predefined or scoped custom role reference; the core never presets a role."
  }

  validation {
    condition     = alltrue([for lane in var.lanes : lane.secret_cmek_key_name == null ? (lane.key_authorizer_role == null && lane.key_authorizer_member == null) : (lane.key_authorizer_role != null && lane.key_authorizer_member != null && can(regex("^projects/[^/]+/locations/[^/]+/keyRings/[^/]+/cryptoKeys/[^/]+$", lane.secret_cmek_key_name)) && can(regex("^(roles|organizations/[0-9]+/roles|projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/roles)/[a-zA-Z0-9._-]+$", lane.key_authorizer_role)) && can(regex("^serviceAccount:service-[0-9]+@gcp-sa-secretmanager\\.iam\\.gserviceaccount\\.com$", lane.key_authorizer_member)))])
    error_message = "The customer-managed encryption form is never half-declared: a lane secret either carries no key reference at all, or carries the full KMS key resource name together with the key-authorizer role and the platform's fully formed secret-manager service-agent member of the credential host project."
  }

  validation {
    condition     = alltrue([for lane in var.lanes : length(lane.variable_names.wif_provider) > 0 && length(lane.variable_names.service_account) > 0 && length(lane.variable_names.project_id) > 0])
    error_message = "Every lane must declare all three variable names of the lane contract (the federation provider reference, the service-account identity and the credential host project); a partially declared contract leaves the lane unable to resolve its credential."
  }

  validation {
    condition     = length(distinct([for lane in var.lanes : lane.service_account_id])) == length(var.lanes)
    error_message = "Every lane binds exactly one service account: the service-account identifiers must be distinct across the declared lanes, never shared between two lanes."
  }

  validation {
    condition     = length(distinct([for lane in var.lanes : lane.secret_id])) == length(var.lanes)
    error_message = "Every lane reads exactly one tenant-scoped secret: the secret identifiers must be distinct across the declared lanes; one gateway key shared across two lanes is the prohibited form."
  }
}
