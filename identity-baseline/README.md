# Foundation area: identity-baseline

The organization-level identity and access baseline: the group and principal
structure every zone and platform boundary derives from, and the anchoring
conventions for workload identity.

## Boundary

- Never carries organization, tenant, identity, secret or registry bindings;
  group addresses, display names, descriptions, parents and every concrete
  value are instance-supplied.
- The first governed infrastructure change for this area (DPI-19) lands the
  organization-level Cloud Identity group surface: the engine is the sole
  birth and mutation channel of the group objects — the declaration chain
  of the operator access classes applies to the group object itself —
  while the membership administration stays on the organization
  identity plane and never touches a binding. The area creates groups
  exclusively through the engine-managed group surface, never by hand.
- Never contains key material, credentials, live state, plans, or variable
  binding files.

## State backend

This root's state lives in the foundation state bucket: the `gcs` backend
block references the instance-bound foundation state-home bucket, and the
state-key grammar prefix identifies exactly this root (`identity-baseline`)
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
`variables.tofutest.hcl` carries the acceptance run of the valid identity
baseline set and one rejection run per condition and per naming-rule clause,
executed through `tofu test` in plan mode with refresh disabled; no run
creates infrastructure. Because this root carries the encryption block, its
initialization resolves the engine key, and because it carries the backend
block, its plan surface requires the initialized backend, so the behavioral
run executes in the governed execution window where the key is reachable and
the foundation bucket exists; the concrete key reference is supplied
through the instance-bound variable channel (a gitignored `*.tfvars`),
never committed.
