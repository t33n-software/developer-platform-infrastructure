# Foundation area: folders

The folder hierarchy that projects are placed under: the structural grouping
layer between the organization node and the individual trust-zone and
platform projects.

## Boundary

- Never carries organization, tenant, identity, secret or registry bindings;
  folder names, parents and placements, project identifiers, billing
  references and label values are instance-supplied.
- The first governed infrastructure change for this area (DPI-18) lands three
  engine-managed surfaces: the folder hierarchy (`google_folder`), the folder
  IAM member surface (`google_folder_iam_member`) and the project placement
  surface (`google_project`). The standing interim carrier bindings of the
  folder-plane mutation class are the engine-managed surface whose future
  retirement into the just-in-time form runs through the engine; the area
  grants folder IAM memberships and project placements exclusively through
  these surfaces — never by hand.
- Never contains key material, credentials, live state, plans, or variable
  binding files.

## State backend

This root's state lives in the foundation state bucket: the `gcs` backend
block references the instance-bound foundation state-home bucket, and the
state-key grammar prefix identifies exactly this root (`folders`) and
nothing else. The bucket is provisioned through the state-home area's
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
`variables.tofutest.hcl` carries the acceptance run of the valid
folder-plane set and one rejection run per condition and per naming-rule
clause, executed through `tofu test` in plan mode with refresh disabled; no
run creates infrastructure. Because this root carries the encryption block,
its initialization resolves the engine key, and because it carries the
backend block, its plan surface requires the initialized backend, so the
behavioral run executes in the governed execution window where the key is
reachable and the foundation bucket exists; the concrete key reference is
supplied through the instance-bound variable channel (a gitignored
`*.tfvars`), never committed.