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

## State backend

This area is a pinned OpenTofu root: its state lives in the foundation state
home bucket provisioned by the `state-home` area's governed birth path, under
the state-key grammar prefix `custom-properties`. The root consumes that state
home and never provisions state infrastructure of its own. Every state and plan
artifact is client-side encrypted with AES-256-GCM through the organization key
management, fail-closed enforced, before it reaches the backend — the
engine layer of the dual fortress state-encryption standard. The bucket name
and the engine key reference are instance-bound variables; the concrete values
never appear in this core, and the backend block carries no backend-side
encryption option because the client-side engine layer is the control.

## Execution contract

The target of every provider call of this root is declared as infrastructure
(the DPI-33 precedent): the `provider "github"` block binds the instance-bound
`organization` variable through the provider's forward-compatible `owner`
argument (the pinned provider documents `organization` as deprecated and
removed in a future major release), so a lane identity that can reach more than
one organization can never silently retarget this projection — a missing or
malformed organization fails closed at plan time. The execution lane supplies
the token only, never the `GITHUB_OWNER` or `GITHUB_ORGANIZATION` environment
coordinate: the pinned provider's documented precedence places those above the
configuration until the future major release fixes the bug, and the plan gate
read-back of the import IDs is the target verifier. Credentials are never
declared and never appear in this repository: the applying lane's identity
authenticates through the pinned provider's token channel, proven against the
provider documentation at the pinned version.

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
