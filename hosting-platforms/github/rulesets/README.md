# Foundation area: hosting-platforms/github/rulesets

The GitHub organization ruleset projection of the developer platform
infrastructure core: it applies the canonical organization ruleset payloads to
the GitHub organization through the exactly pinned `integrations/github`
provider.

## Coverage contract

- Projects every payload supplied through `rulesets` as one organization
  ruleset (`branch`, `tag`, or `push` target) with its conditions, rules,
  enforcement state, and bypass actors.
- Pairs `ref_name` with exactly one repository selector for `branch` and `tag`
  targets and carries the repository selector without `ref_name` for `push`
  targets, matching the organization ruleset schema.
- Orders nothing implicitly against other areas; the caller sequences the
  projection (property definitions and assignments before class-partitioned
  rulesets; tag rulesets only after their bypass identity is verified).
- `enforcement` arrives from the caller as `active` or `disabled`; `evaluate`
  is bound to the Enterprise Cloud entitlement and is never assumed.

## Boundary

- Never carries a ruleset name, ref pattern, repository selector, rule value,
  or bypass actor of its own; payloads are decoded by the caller from the
  pinned canonical ruleset artifacts, and bypass actor identities arrive from
  the organization instance bindings.
- Never carries credentials, tokens, organization names, live state, plans, or
  variable binding files; the provider authenticates through the applying
  lane's identity.
- Never weakens a payload: the projected ruleset is the pinned artifact, and a
  local edit is drift that the instance reconciles back to the pin.
- Creates no custom properties; property definitions are projected through the
  sibling `custom-properties` area.
