# Foundation area: policy

The organization policy foundation: the constraint anchors that keep every
project in the organization on the governed baseline (for example uniform
bucket-level access, public access prevention, and service account key
restrictions).

## Boundary

- Never carries organization, tenant, identity, secret or registry bindings;
  constraint selections and their values are instance-supplied.
- Sets no constraints yet; resources land with the first governed
  infrastructure change for this area.
- Never contains key material, credentials, live state, plans, or variable
  binding files.
