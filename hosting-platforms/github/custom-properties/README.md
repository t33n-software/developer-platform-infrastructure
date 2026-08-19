# Foundation area: hosting-platforms/github/custom-properties

The GitHub organization custom-property projection of the developer platform
infrastructure core: it applies the canonical property definitions and the
organization's repository assignments to the GitHub organization through the
exactly pinned `integrations/github` provider.

## Coverage contract

- Projects every definition supplied through `definitions` as one
  organization custom property (value type, allowed values, requirement,
  default, editability boundary).
- Projects every repository value supplied through `assignments`; an
  assignment referencing an undefined property fails at plan time, and every
  assignment is ordered after the definition projection.
- The projection runs before any class-partitioned ruleset activation: a
  ruleset whose selector property does not exist binds zero repositories.

## Boundary

- Never carries a property definition, allowed value, description, or
  repository assignment of its own; definitions are decoded by the caller
  from the pinned canonical definition artifacts, and assignments arrive from
  the organization instance bindings.
- Never relaxes `values_editable_by` beyond `org_actors`; class membership is
  a governance decision, never a repository-local one.
- Never contains credentials, tokens, organization names, live state, plans,
  or variable binding files; the provider authenticates through the applying
  lane's identity.
- Creates no rulesets; organization ruleset payloads are projected through the
  sibling `rulesets` area from the pinned canonical ruleset artifacts.
