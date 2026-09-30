# Foundation area: organization

The organization node and the placement of projects beneath it: the anchor
for the folder hierarchy, the service-perimeter and access-context control
plane, organization-wide policy constraints, and the central identity and
audit boundary.

## Organization node coverage contract

The organization node is the canonical standard. It covers:

- folder placement of projects;
- the service-perimeter and access-context control plane;
- organization-wide policy constraints;
- the central identity and audit boundary.

Without an organization node these aspects drop out: projects lie flat in the
account, there is no service perimeter or access context manager, and
organization-wide policies are compensated with equivalent project-level
constraints. Operating without an organization node is optionally possible as
a documented deviation; the deviation and its compensations are recorded in
the organization instance, projects created before the organization node are
migrated into it later, and the service perimeter is retrofitted then.

## Boundary

- Never carries organization, tenant, identity, secret or registry bindings;
  organization identifiers, domain references and placement values are
  instance-supplied.
- The first governed infrastructure change for this area (DPI-17) lands the
  organization IAM member surface: the engine-managed organization plane.
  The area creates no folders, policies or perimeters (those belong to their
  own foundation areas); organization IAM memberships are granted
  exclusively through the engine-managed member surface, and the standing
  interim carrier binding of the organization-plane mutation class is the
  engine-managed surface whose future retirement into the just-in-time form
  runs through the engine.
- Never contains key material, credentials, live state, plans, or variable
  binding files.

## State backend

This root's state lives in the foundation state bucket: the `gcs` backend
block references the instance-bound foundation state-home bucket, and the
state-key grammar prefix identifies exactly this root (`organization`) and
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
organization-plane set and one rejection run per condition and per
naming-rule clause, executed through `tofu test` in plan mode with refresh
disabled; no run creates infrastructure. Because this root carries the
encryption block, its initialization resolves the engine key, and because it
carries the backend block, its plan surface requires the initialized backend,
so the behavioral run executes in the governed execution window where the
key is reachable and the foundation bucket exists; the concrete key
reference is supplied through the instance-bound variable channel (a
gitignored `*.tfvars`), never committed.
