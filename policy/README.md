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
