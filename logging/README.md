# Foundation area: logging

The organization-level audit logging foundation: the routing and export
anchors that carry administrative and data-access audit trails into the
evidence boundary.

## Boundary

- Never carries organization, tenant, identity, secret or registry bindings;
  sink names, destinations and filters are instance-supplied values.
- Creates no sinks or exports yet; resources land with the first governed
  infrastructure change for this area.
- Never contains key material, credentials, live state, plans, or variable
  binding files.
