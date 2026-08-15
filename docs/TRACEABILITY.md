# Traceability

## Tickets

| Ticket | Change | Status |
|---|---|---|
| DPI-1 | Establish the developer platform infrastructure core: the seven canonical foundation areas (organization, folders, identity-baseline, kms, logging, network, policy) as pinned OpenTofu roots, the OpenTofu engine convention, source-quality gates, CodeQL, dependency admission review, Dependabot, Lefthook, and importable Rulesets. | In progress |
| DPI-2 | Migrate the module path to the `t33n-software` organization namespace; add the LF line-ending contract (`.gitattributes`) and the push-protections Ruleset source `00-push-protections.json` in the verified GitHub export format. | In progress |

## Scope boundaries

- DPI-1 delivers the organization-agnostic source core only. It does not
  create Google Cloud projects, enable APIs, or provision live foundation
  resources; the organization instance provisions those through the governed
  infrastructure change.
- The seven foundation areas are pinned OpenTofu roots. Their resources land
  with the first governed infrastructure change per area; no concrete
  organization values exist in this core.
- The core contains no concrete organization or tenant bindings, no live
  state or plans, and no variable binding files.
- The `release/*` and `support/*` branch families and their Rulesets are
  activated only with a complete governed release lifecycle.
