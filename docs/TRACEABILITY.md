# Traceability

## Tickets

| Ticket | Change | Status |
|---|---|---|
| DPI-1 | Establish the developer platform infrastructure core: the seven canonical foundation areas (organization, folders, identity-baseline, kms, logging, network, policy) as pinned OpenTofu roots, the OpenTofu engine convention, source-quality gates, CodeQL, dependency admission review, Dependabot, Lefthook, and importable Rulesets. | In progress |
| DPI-2 | Migrate the module path to the `t33n-software` organization namespace; add the LF line-ending contract (`.gitattributes`) and the push-protections Ruleset source `00-push-protections.json` in the verified GitHub export format. | In progress |
| DPI-3 | Align the Go 1.26.6 toolchain and source gates with the supply chain fortress contract: pinned `tools/` module with govulncheck, staticcheck, and Lefthook; fail-closed vulnerability analysis; Lefthook configuration validation and commit-msg hook; daily CI re-scan. | In progress |
| DPI-5 | Add the hosting-platform projection area `hosting-platforms/github/custom-properties/`: a value-free OpenTofu module that projects the canonical GitHub organization custom-property definitions and the instance-bound repository assignments through the exactly pinned `integrations/github` provider, ordered before any class-partitioned ruleset activation. | In progress |

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
