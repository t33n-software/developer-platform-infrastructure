# Foundation area: kms

The key management foundation: key rings and key references that platform and
trust-zone boundaries use for CMEK and signing-adjacent encryption needs.

## Boundary

- Never carries organization, tenant, identity, secret or registry bindings;
  key ring names, key names, locations and rotation settings are
  instance-supplied values.
- Never contains key material; only key ring and key references are ever
  expressed.
- Creates no key rings or keys yet; resources land with the first governed
  infrastructure change for this area.
- Never contains credentials, live state, plans, or variable binding files.
