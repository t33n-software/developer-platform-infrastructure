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
- The declared `review_posture` input maps to the three review-gate
  parameters (`required_approving_review_count`, `require_code_owner_review`,
  `require_last_push_approval`) exactly once, here: `solo` lowers them at
  every import, `multi` projects the pinned payloads unchanged, an unknown
  posture fails closed. The posture is an instance-declared organization
  fact; the module never infers it from environment coordinates or member
  counts, and it never touches any other rule value.

## Boundary

- Never carries a ruleset name, ref pattern, repository selector, rule value,
  or bypass actor of its own; payloads are decoded by the caller from the
  pinned canonical ruleset artifacts, and bypass actor identities arrive from
  the organization instance bindings.
- Never carries credentials, tokens, organization names, live state, plans, or
  variable binding files; the provider authenticates through the applying
  lane's identity.
- Never weakens a payload: the projected ruleset is the pinned artifact, and a
  local edit is drift that the instance reconciles back to the pin. The only
  declared projection transform is the review-posture mapping above; the
  canonical artifacts keep the multi-member target values and the posture is
  a reviewed instance declaration, never a silent default.
- Creates no custom properties; property definitions are projected through the
  sibling `custom-properties` area.
