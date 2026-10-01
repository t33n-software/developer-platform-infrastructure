# Foundation area: hosting-platforms/github/repository-settings

The GitHub repository-settings projection of the developer platform
infrastructure core: it projects the fleet repository settings target values
(`allow_rebase_merge`, `delete_branch_on_merge`) to the governed repositories
through the exactly pinned `integrations/github` provider.

## Coverage contract

- Projects every repository supplied through `repository_settings` as one
  `github_repository` resource carrying exactly the two fleet-governed
  settings flags; every target value arrives from the organization instance
  bindings.
- Governs the two settings the platform default leaves divergent from the
  fleet convention — the same two flags every governed birth sets explicitly
  (rebase merging disabled, head-branch deletion enabled for working
  branches).
- Holds every non-governed optional repository attribute at its remote value
  through a curated `ignore_changes` set: the projection never clears a
  description, disables an issue tracker, or flips a merge-method capability
  it was not asked to govern. Extending the governed set is its own reviewed
  change.

## Adoption contract

- Repositories are born through the platform birth form, never through this
  module: every projected repository already exists when the module first
  plans it.
- OpenTofu rejects import blocks inside child modules, so the adoption
  belongs to the consuming root: the organization instance carries one
  root-level `for_each` import per repository map entry, targeting
  `module.<name>.github_repository.settings[<repository>]`, with the import
  ID equal to the repository name. Without that adoption the first plan
  would propose creating repositories that already exist.
- The applying lane's identity needs the `contents:write` permission;
  without it the provider ignores the merge-method arguments and produces
  confusing diffs (the provider's documented GitHub App behavior).

## Ready state

The surface is ready for instance consumption at an exact, immutable module
pin: the organization instance declares its per-repository target values as
reviewed instance configuration and binds them against this module, the
instance-side settings bindings flip from `planned` to `bound` against this
ready state, and the repository onboarding birth documents re-reference both.
The resources land with the first governed infrastructure change of this
area — the instance's adoption import blocks and apply.

## Boundary

- Never carries a repository name, settings value, organization value, or
  default of its own; every target value arrives from the organization
  instance bindings.
- Never adopts repositories itself: the module carries no import blocks,
  because OpenTofu allows import blocks only in the root module.
- Never governs a merge-method availability, description, or repository
  feature toggle: the curated ignore set holds those at their remote
  values.
- Never contains credentials, tokens, organization names, live state,
  plans, or variable binding files; the provider authenticates through the
  applying lane's identity.
- Creates no custom properties or rulesets; those are projected through the
  sibling `custom-properties` and `rulesets` areas.