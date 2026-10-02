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

## Group birth semantics

The platform's group birth mechanics govern the label surface of the group
objects: the create request carries the Google Group base type label
(`cloudidentity.googleapis.com/groups.discussion_forum`) — the default group
type — while the security label (`cloudidentity.googleapis.com/groups.security`)
is an additional immutable label of an existing group. The platform rejects
the direct specification of the security label in the create request with the
documented 400 "security label cannot be specified directly", and once the
label is added it can never be removed — the one-way ratchet is a
platform-enforced fortress invariant, so the access control class cannot be
silently downgraded. The declaration therefore composes the base type label
always and the security label additionally through the merge form, and the
governed engine birth applies them in the platform-proven two-phase sequenced
form: phase 1 creates the group with the base type label, phase 2 adds the
immutable security label through the engine's update — the same sequencing
the `--group-type=security` form implements internally. The phase-1
intermediate value is the documented birth mechanic, and the end state stays
byte-exact to the instance binding. The offline verification (the variable
fixture, the schema introspection) cannot prove the platform's create
semantics — the live plan-gated apply is the behavioral verifier, and the
400 class is the designed fail-closed detection.

The import path of an existing live group object is the plan-gated
declarative import block: the import ID carries the `groups/{{name}}`
resource form proven against the pinned provider documentation, and a
destroy in an import plan is the defect proof that stops the window, never
an authorization basis. The platform never returns the initial group
configuration after birth, so the import state cannot carry it and a
declared value forces the replacement of the live object; the declaration
therefore carries the lifecycle ignore-changes form for exactly that field
— the birth path still applies it, imported objects ignore it, and the
form is never a general ignore-changes license (the description class
stays a managed, mutable surface bound to its exact live form). A group
that is no longer describable retains its email reservation: the create
fails with the documented 409 Error(2018) while the describe answers
non-existence, so a non-existence probe never proves email freedom — the
describe probe binds the object state before any group create, and a 409
is the proof of a reserved or live address, never a retry trigger.

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
