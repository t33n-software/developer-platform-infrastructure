# Foundation area: policy

The organization-level policy foundation: the constraint anchors that keep
every resource of the organization on the governed baseline — currently the
destruction discipline of the organization key management (the state
encryption reference's key layer).

## Boundary

- Never carries organization, tenant, identity, secret or registry bindings;
  the organization identifier, the constraint value and the enforcement
  posture are instance-supplied values.
- Never contains key material, credentials, live state, plans, or variable
  binding files.
- The engine is the sole birth and mutation channel of the organization
  policies (DPI-29): the area creates them exclusively through the
  engine-managed surfaces, never by hand. Both policies pin the
  provider-native deletion policy to PREVENT: a policy's destruction stops
  its discipline silently while the organization survives; a retirement
  runs through the explicit abandon path.

## Quota attribution

The organization-policy API is a quota-gated surface: an engine run of this
root attributes its API calls to a quota project. The binding is declared,
never environmental folklore: the provider block carries the
`user_project_override` posture with the instance-bound `billing_project`
(the pinned provider sends the user-project attribution only in exactly this
form), and the API enablement itself is declared as
`google_project_service.orgpolicy_api` with the provider-native deletion
policy pinned to PREVENT — disabling the API would stop the enforcement
channel of every organization policy silently. Both policy surfaces order
their birth behind this declared precondition.

The quota carrier is an instance-bound value; the core never presets one.
The carrier is chosen by the hierarchy position of the root: an
organization-plane root runs outside the trust-zone service perimeter, so a
carrier project inside the perimeter would break its calls through the
perimeter rule — the instance binds a carrier outside it. The client-side
engine layer of the state and plan encryption reads the key through the
Google client libraries outside the provider configuration, so the governed
execution window supplies the same carrier to that layer through the
per-run quota environment channel of the engine process; the local
application default credentials keep their quota field absent — a permanent
quota binding would break cross-perimeter roots (the proven class).

## Import semantics

The import path of an existing live organization policy is the plan-gated
declarative import block: the import ID carries the resource form proven
against the pinned provider documentation — `{{parent}}/policies/{{name}}`
(the parent carries the `organizations/<id>` form and the name carries the
constraint-qualified policy form) — and a destroy in an import plan is the
defect proof that stops the window, never an authorization basis.

## State backend

This root's state lives in the foundation state bucket: the `gcs` backend
block references the instance-bound foundation state-home bucket, and the
state-key grammar prefix identifies exactly this root (`policy`)
and nothing else. The bucket is provisioned through the state-home area's
governed birth path; this root consumes the foundation state home and never
provisions state infrastructure of its own. The client-side engine layer of
the dual fortress state-encryption standard (AES-256-GCM through the
organization key management, fail-closed enforced on state and plan alike)
protects every state and plan artifact of this root before it reaches the
backend.

## Verification

Every custom condition of this root is proven with concrete values before it
may merge — the static gate layer (format check, initialization, validation)
never evaluates a condition body, so the proof is behavioral:
`variables.tofutest.hcl` carries the acceptance run of the valid policy set
and one rejection run per condition, executed through `tofu test` in plan
mode with refresh disabled; no run creates infrastructure. Because this root
carries the encryption block, its initialization resolves the engine key,
and because it carries the backend block, its plan surface requires the
initialized backend, so the behavioral run executes in the governed
execution window where the key is reachable and the foundation bucket
exists; the concrete key reference is supplied through the instance-bound
variable channel (a gitignored `*.tfvars`), never committed.
