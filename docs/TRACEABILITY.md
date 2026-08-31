# Traceability

## Tickets

| Ticket | Change | Status |
|---|---|---|
| DPI-1 | Establish the developer platform infrastructure core: the seven canonical foundation areas (organization, folders, identity-baseline, kms, logging, network, policy) as pinned OpenTofu roots, the OpenTofu engine convention, source-quality gates, CodeQL, dependency admission review, Dependabot, Lefthook, and importable Rulesets. | In progress |
| DPI-2 | Migrate the module path to the `t33n-software` organization namespace; add the LF line-ending contract (`.gitattributes`) and the push-protections Ruleset source `00-push-protections.json` in the verified GitHub export format. | In progress |
| DPI-3 | Align the Go 1.26.6 toolchain and source gates with the supply chain fortress contract: pinned `tools/` module with govulncheck, staticcheck, and Lefthook; fail-closed vulnerability analysis; Lefthook configuration validation and commit-msg hook; daily CI re-scan. | In progress |
| DPI-5 | Add the hosting-platform projection area `hosting-platforms/github/custom-properties/`: a value-free OpenTofu module that projects the canonical GitHub organization custom-property definitions and the instance-bound repository assignments through the exactly pinned `integrations/github` provider, ordered before any class-partitioned ruleset activation. | In progress |
| DPI-6 | Add the hosting-platform projection area `hosting-platforms/github/rulesets/`: a value-free OpenTofu module that projects the pinned canonical GitHub organization ruleset payloads (branch, tag, and push targets, including the classless tag-governance family) through the exactly pinned `integrations/github` provider, with bypass actor identities arriving exclusively from the organization instance bindings. | In progress |
| DPI-7 | Adopt the canonical repo surface with the `opentofu@1` capability pack: the byte-identical canonical callers (`ci.yml`, `codeql.yml`, `dependency-review.yml`) pinned to the repository-governance home at the exact-toolchain stand; the thin `canonical-conformance.yml` lane running the home verifier; the canonical file family and the materialized `.github/CODEOWNERS`; the `repo-bindings.json` tenant manifest; the schema-v4 quality configuration declaring `extends: ["opentofu@1"]`; the tooling-module pins for `quality-gate` and `check-coverage` (the provision-capable go-quality-authority stand), `verify-canonical` (the extends-capable repository-governance stand), and the shared-kernel module requirement for the pack registry resolution; the conventional `--version` surface of the development tools; the OpenTofu gates moved into the pack with the repository-local setup steps and the duplicated engine convention document removed; and the packaging contract bound to the manifest. | In progress |
| DPI-8 | Reference the canonical gate chain through the tooling module pin: the repo-local chain copies `cmd/build` and `cmd/check-coverage` are removed (the `cmd/` tree carries no repository tooling anymore), the quality configuration invokes the go-quality-authority orchestrator via `go tool -modfile tools/go.mod quality-gate` with the `opentofu@1` pack declaration unchanged, the restated `defaults` block is dropped for the schema-owned `includeFamilies` default (SCG-9), and the contract guards prove the canonical invocation, the absent `defaults` block, and the absence of both copies fail-closed. | In progress |
| DPI-9 | Onboard the license-hub render-and-verify lane in the strengthened unit form: the tenant values `license.values.json` and the digest-pinned lock `license.lock.json` (template `license-hub/templates/custom/norepublish/NoRepublish-1.0.0.hbs`, version 1.0.0), the rendered `LICENSE` and `LICENSES/LicenseRef-developer-platform-infrastructure-NoRepublish-1.0.txt` instance proven byte-identical against the canonical render, the binding manifest flip `licenseHub: true`, the coupled tooling-module pins for the catalog-admitted license CLI, the license-content-proof verifier, and the go-quality-authority catalog stand, the three callers converged byte-identical to the reissued canonical pin, and the conformance lane re-bound to it — activating the merge-blocking license content proof inside the canonical conformance check. | In progress |

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
