# Foundation area: gateway-identity

The engine-managed binding root of the hosting-native CI credential chain: the
organization's gateway lanes — governed repository workflows that need exactly
one cloud-side credential — are bound here as declared infrastructure across
both sides of the contract (the cloud identity surface and the hosting-platform
surface) in one atomic root.

## Coverage contract

- One declared channel identity of the infrastructure-apply class
  (`github_app_installation_repository` per lane): the machine identity that
  converges this root — its app slug and organization installation id arrive
  as the instance-bound `channel` coordinate, and the installation selection
  binds exactly the lane repositories the declaration names. The app birth
  stays a human-gated act outside the declaration (the capability-class law of
  the hosting-platform machine-identity classification convention; the pinned
  provider carries no app-birth resource), so the installation boundary is
  declared truth, never console state.
- One estate workload identity pool (`google_iam_workload_identity_pool`): the
  trust boundary every lane provider federates into, per the hosting-native CI
  credentials convention's one-pool-per-instance rule.
- One GitHub OIDC provider per lane
  (`google_iam_workload_identity_pool_provider`): the attribute mapping projects
  the token subject claims the lane contract binds on, and the attribute
  condition binds the exact repository, the owning organization and the
  protected environment — a fork, a foreign repository, a foreign organization
  or an unbound environment fails the exchange before any secret read.
- One federated service account per lane (`google_service_account`) plus its
  federation binding (`google_service_account_iam_member`): the principal set is
  derived from the pool's own resource name and the lane's declared repository
  attribute, so the binding scope equals the provider condition and never a
  wildcard.
- One tenant-scoped secret container per lane (`google_secret_manager_secret`)
  plus its single-secret accessor binding
  (`google_secret_manager_secret_iam_member`): resource-sharp on the lane's own
  secret, never a project-wide grant. A lane secret protected by a
  customer-managed key additionally carries the platform service-agent key
  authorization (`google_kms_crypto_key_iam_member`).
- The hosting-platform side of the same contract
  (`github_repository_environment`, `github_actions_environment_variable`): the
  protected environment and the three non-secret coordinates the lane resolves
  — the provider reference, the service-account identity and the credential host
  project — every value derived from the declared cloud resources so the
  workflow surface and the cloud surface cannot drift apart.

## Execution contract

The credential host project and the GitHub organization target are declared as
instance-bound variables (the DPI-33 and DPI-38 precedents), so a lane identity
that can reach more than one project or organization can never silently
retarget this binding: a missing or malformed target fails closed at plan time.
The GitHub provider binds the organization through the pinned provider's
forward-compatible `owner` argument, and the applying lane supplies only its own
token — never the `GITHUB_OWNER` or `GITHUB_ORGANIZATION` environment
coordinate. The window that first converges this root authenticates through the
bootstrap form the class law permits for exactly that act (a time-boxed,
narrowly scoped credential whose expiry is set before first use and which is
revoked at window close): the pinned provider documents the installation
surfaces as incompatible with GitHub App installation authentication, so the
channel identity cannot yet converge its own birth. From the moment the
installation exists, every later convergence run authenticates through the
channel identity itself.

## Credential boundary

The secret payload is never part of this declaration, this repository, the
engine state, a plan artifact or a log. This root declares the secret
**container** (identifier, labels, replication and encryption form); the value
enters through the platform's own out-of-band channel and is rotated there. No
service-account key is ever declared or produced: the lane authenticates through
the federation only, which is the no-exported-key law expressed as
infrastructure.

## Import semantics

The provider-proven import ID forms of the surfaces this root declares (all read
from the pinned provider documentation, never assumed):

- pool: `projects/{{project}}/locations/global/workloadIdentityPools/{{workload_identity_pool_id}}`
- provider: `projects/{{project}}/locations/global/workloadIdentityPools/{{workload_identity_pool_id}}/providers/{{workload_identity_pool_provider_id}}`
- service account: `projects/{{project_id}}/serviceAccounts/{{email}}`
- secret: `projects/{{project}}/secrets/{{secret_id}}`
- secret IAM member: `projects/{{project}}/secrets/{{secret_id}} {{role}} {{member}}`
- service-account IAM member: `{{service_account_id}} {{role}} {{member}}`
- environment variable: `{{repository}}:{{environment}}:{{variable_name}}` (a colon
  inside an environment name needs escaping outside the declaration, which the
  lane validation rejects)
- app installation repository: `{{installation_id}}:{{repository}}`

An existing live surface enters through the plan-gated declarative import block;
a destroy inside an import plan is the defect proof that stops the window.

## State backend

This area is a pinned OpenTofu root: its state lives in the foundation state
home bucket provisioned by the `state-home` area's governed birth path, under the
state-key grammar prefix `gateway-identity`. The root consumes that state home
and never provisions state infrastructure of its own. Every state and plan
artifact is client-side encrypted with AES-256-GCM through the organization key
management, fail-closed enforced, before it reaches the backend — the engine
layer of the dual fortress state-encryption standard. Because this root is the
organization's credential-binding surface, its state carries every federation
condition and IAM binding of the lanes, which makes the engine layer the control
and leaves the backend block without any backend-side encryption option.

## Verification

The behavioral proof runs in two files of this module directory:
`variables.tofutest.hcl` carries the acceptance run plus one rejection run per
condition and per naming-rule clause of the lane contract, and
`channel.tofutest.hcl` carries the channel binding proof (the per-lane
installation selection plus one rejection run per validation clause of the
`channel` coordinate). The split follows the file-size governance of committed
productive code surfaces; the engine discovers every `*.tofutest.hcl` of the
module, so the division changes nothing about execution. Both run through
`tofu test` in the governed window, because the encryption-carrying root
resolves the engine key at initialization. The live proof of the platform's
condition semantics is the governed window itself: the plan gate (adds and
imports only, zero destroys), the activation read-backs of provider conditions,
IAM bindings, secret names and the installation permission surface against the
declared ceiling, and the zero-drift plan.

## Boundary

- Never carries a concrete organization, project, repository, environment,
  provider, service-account, secret identifier, role or label value; every
  concrete value arrives from the organization instance bindings, and the core
  never presets one.
- Never declares, caches or projects a secret value, a token, a private key or
  an authorization header.
- Never produces a service-account key and never grants a wildcard secret or
  project-wide accessor surface.
- Creates no gateway, no model binding and no verdict data: this root binds
  identities and credentials only; the consumed model identifiers stay under the
  gateway selection convention's exact-ID pinning law on the consuming lane.
