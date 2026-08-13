# Foundation area: network

The shared network foundation: the VPC, DNS and egress anchors the trust
zones and platform boundaries attach to, including the private connectivity
substrate.

## Boundary

- Never carries organization, tenant, identity, secret or registry bindings;
  network names, subnets, DNS zones and egress allowlists are
  instance-supplied values.
- Creates no VPCs, subnets, firewall rules, DNS zones or records yet;
  resources land with the first governed infrastructure change for this area.
- Never contains key material, credentials, live state, plans, or variable
  binding files.
