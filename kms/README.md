# Foundation area: kms

The organization-wide key management foundation: the key rings, the crypto
keys and the key-scoped IAM bindings that platform and trust-zone boundaries
use for CMEK and signing-adjacent encryption needs.

## Boundary

- Never carries organization, tenant, identity, secret or registry bindings;
  key ring names, projects, locations, key names, purposes, algorithms,
  protection levels, schedules, labels, roles and members are
  instance-supplied values.
- Never contains key material; only key ring, key and binding references are
  ever expressed.
- Never contains credentials, live state, plans, or variable binding files.
- The engine is the sole birth and mutation channel of the key rings, the
  crypto keys and the key IAM member bindings (DPI-25): the area creates
  them exclusively through the engine-managed surfaces, never by hand. The
  key rings carry the fail-closed prevent-destroy lifecycle (the platform
  never deletes a key ring, so a destroy would silently unmanage the ring
  while the live object survives), and the crypto keys pin the
  provider-native deletion policy to PREVENT (the destruction of a
  state-encryption key renders every artifact encrypted with it
  irrecoverable); a retirement runs through the explicit abandon path.
- The pinned provider carries no next-rotation-time argument: the platform
  owns the rotation schedule, so no declared field can drift against it.

## Import semantics

The import path of an existing live key ring, key or key IAM member is the
plan-gated declarative import block: the import ID carries the resource
forms proven against the pinned provider documentation — the key ring
`projects/{{project}}/locations/{{location}}/keyRings/{{name}}`, the crypto
key `{{key_ring}}/cryptoKeys/{{name}}` and the IAM member
`{{project}}/{{location}}/{{key_ring}}/{{key}} <role> <member>`
(space-delimited) — and a destroy in an import plan is the defect proof
that stops the window, never an authorization basis.

## State backend

This root's state lives in the foundation state bucket: the `gcs` backend
block references the instance-bound foundation state-home bucket, and the
state-key grammar prefix identifies exactly this root (`kms`)
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
`variables.tofutest.hcl` carries the acceptance run of the valid key
management set and one rejection run per condition and per naming-rule
clause, executed through `tofu test` in plan mode with refresh disabled; no
run creates infrastructure. Because this root carries the encryption block,
its initialization resolves the engine key, and because it carries the
backend block, its plan surface requires the initialized backend, so the
behavioral run executes in the governed execution window where the key is
reachable and the foundation bucket exists; the concrete key reference is
supplied through the instance-bound variable channel (a gitignored
`*.tfvars`), never committed.
