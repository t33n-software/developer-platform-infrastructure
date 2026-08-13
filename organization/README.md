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
- Creates no folders, policies, perimeters or memberships yet; resources land
  with the first governed infrastructure change for this area.
- Never contains key material, credentials, live state, plans, or variable
  binding files.
