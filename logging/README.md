# Foundation area: logging

The organization-level audit logging foundation: the routing and export
anchors that carry administrative and data-access audit trails into the
evidence boundary.

## Boundary

- Never carries organization, tenant, identity, secret or registry bindings;
  anchor names, destinations and filters are instance-supplied values.
- Never contains key material, credentials, live state, plans, or variable
  binding files.
- The engine is the sole birth and mutation channel of the organization-
  plane audit export anchors (DPI-26): the area creates them exclusively
  through the engine-managed surface, never by hand. Every anchor is scoped
  to the organization level itself — the child inclusion stays disabled, so
  the anchor never duplicates the zone audit exports of the trust-zone
  stacks — and the fail-closed prevent form pins the provider-native
  deletion policy to PREVENT (an anchor's destruction stops the organization
  plane's audit trail silently while the live evidence boundary survives); a
  retirement runs through the explicit abandon path.

## Writer grant semantics

The writer of an audit export anchor is the platform's own logging service
identity for the anchor (the provider's computed writer identity): the
pinned provider documentation exposes it as a computed attribute with no
deterministic pre-birth form, so per the organization-plane audit export
convention the standing archive write capability follows the anchor's birth
— the evidence-store IAM surface of the dependency-authority infrastructure
declares it at the first governed change after the provisioning read-back
proves the identity, never as a mutation-window grant and never as a
workload identity. The perimeter form of the export writer (an owning
resource outside the zone perimeter writing one bound destination) is part
of the same declared change: the proven writer identity is the deciding
evidence, never a convenience widening.

## Import semantics

The import path of an existing live organization-plane audit export anchor
is the plan-gated declarative import block: the import ID carries the
resource form proven against the pinned provider documentation —
`organizations/{{organization_id}}/sinks/{{sink_id}}` — and a destroy in an
import plan is the defect proof that stops the window, never an
authorization basis.

## State backend

This root's state lives in the foundation state bucket: the `gcs` backend
block references the instance-bound foundation state-home bucket, and the
state-key grammar prefix identifies exactly this root (`logging`)
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
`variables.tofutest.hcl` carries the acceptance run of the valid audit
export anchor set and one rejection run per condition and per naming-rule
clause, executed through `tofu test` in plan mode with refresh disabled; no
run creates infrastructure. Because this root carries the encryption block,
its initialization resolves the engine key, and because it carries the
backend block, its plan surface requires the initialized backend, so the
behavioral run executes in the governed execution window where the key is
reachable and the foundation bucket exists; the concrete key reference is
supplied through the instance-bound variable channel (a gitignored
`*.tfvars`), never committed.
