# Foundation area: gateway-identity

The engine-managed binding root of the hosting-native CI credential chain: the
organization's gateway lanes — governed repository workflows that need exactly
one cloud-side credential — are bound here as declared infrastructure across
both sides of the contract (the cloud identity surface and the hosting-platform
surface) in one atomic root.

## Coverage contract

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
coordinate.

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

The behavioral proof `variables.tofutest.hcl` carries the acceptance run plus one
rejection run per condition and per naming-rule clause; it runs through
`tofu test` in the governed window, because the encryption-carrying root
resolves the engine key at initialization. The live proof of the platform's
condition semantics is the governed window itself: the plan gate (adds and
imports only, zero destroys), the activation read-backs of provider conditions,
IAM bindings and secret names, and the zero-drift plan.

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
