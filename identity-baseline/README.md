# Foundation area: identity-baseline

The organization-level identity and access baseline: the group and principal
structure every zone and platform boundary derives from, and the anchoring
conventions for workload identity.

## Boundary

- Never carries organization, tenant, identity, secret or registry bindings;
  group names, principals and claim mappings are instance-supplied values.
- Creates no groups, memberships, pools or providers yet; resources land with
  the first governed infrastructure change for this area.
- Never contains key material, credentials, live state, plans, or variable
  binding files.
