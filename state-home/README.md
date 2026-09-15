# Foundation area: state-home

The engine-state homes of the organization: exactly one dedicated Cloud
Storage bucket per boundary — the foundation's own state home plus one per
trust zone — holding that boundary's OpenTofu root states and nothing else.
The form is the dual fortress state-encryption standard: every bucket
carries uniform bucket-level access, enforced public access prevention,
object versioning and its mandatory CMEK (the provider layer, with the
second, cryptographically separate key), and this root carries the
client-side engine layer (AES-256-GCM through the organization key
management, fail-closed enforced on state and plan alike).

## State backend

This root's own state lives in the foundation state bucket: the `gcs`
backend block references the state-home entry keyed exactly `foundation`,
and the state-key grammar prefix identifies exactly this root
(`state-home`) and nothing else. The bucket is provisioned through the
organization birth path owned by the operating model: this root is the only
root of the organization that ever applies with local state, and only at
the organization's birth (the birth declaration carries the encryption
block but no backend block, so the birth apply runs on the local backend
with the state encrypted from birth); immediately after the foundation
bucket exists, the backend block joins this root's declaration (a reviewed
change), and the root migrates its own state into the bucket through the
engine's backend migration (`tofu init -migrate-state`). From then on, no
local state exists anywhere. Every zone state home is provisioned through
this root's plan-gated apply — never by the zone's own roots and never by
hand.

## Boundary

- Never carries organization, tenant, identity, secret or registry bindings;
  every concrete value (the bucket names, the projects, the locations, the
  key references, the operator members and the labels) is an
  instance-supplied variable.
- The CMEK key of every state home is mandatory and cryptographically
  separate from the engine key — the two keys are disjoint boundaries,
  proven fail-closed by the variable validations.
- A state bucket never carries a retention policy: the state layer is the
  recovery root, not an archive.
- The area grants exactly `roles/storage.objectAdmin` on each bucket — the
  documented backend credential requirement — resource-sharp per boundary,
  and never constructs members; the instance passes fully formed member
  strings.
- The bucket location of every state home is coupled to its CMEK key ring
  location (a hard platform rule), proven fail-closed by the variable
  validations.
- The backend block is present and final: this root's state lives in the
  foundation state bucket; the only local state the organization ever holds
  is this root's encrypted birth state before its backend migration.

## Verification

Every custom condition of this root is proven with concrete values before it
may merge — the static gate layer (format check, initialization, validation)
never evaluates a condition body, so the proof is behavioral:
`variables.tofutest.hcl` carries the acceptance run of the valid state-home
set and one rejection run per condition and per naming-rule clause, executed
through `tofu test` in plan mode with refresh disabled; no run creates
infrastructure. Because this root carries the encryption block, its
initialization resolves the engine key, and because it carries the backend
block, its plan surface requires the initialized backend, so the behavioral
run executes in the governed execution window where the key is reachable and
the foundation bucket exists; the concrete key reference is supplied through
the instance-bound variable channel (a gitignored `*.tfvars`), never
committed. The static evaluation-safety guard
in the packaging contract (`TestCustomConditionsBindContainsToCollectionArguments`)
is the always-on form: it binds fail-closed that every `contains` call in
every HCL surface of the core resolves its first argument to a collection
type.
