# Developer Platform Infrastructure

`developer-platform-infrastructure` is the organization-agnostic core of the
developer platform foundation modules: organization, folders, identity
baseline, KMS, logging, network, policy, and the hosting-platform projection
areas for GitHub organization custom properties and rulesets.

This repository never contains concrete organization, tenant, project,
identity, network, secret, or registry bindings. Instances consume these
modules only through exact version pins.

## Core boundary

The core owns:

- the seven canonical substrate foundation areas `organization/`,
  `folders/`, `identity-baseline/`, `kms/`, `logging/`, `network/` and
  `policy/`, plus the hosting-platform projection areas
  `hosting-platforms/github/custom-properties/` and
  `hosting-platforms/github/rulesets/`, each a pinned OpenTofu root
  whose resources land with the first governed infrastructure change for that
  area;
- the source-quality gates under `cmd/` and the same-package workflow contract
  tests under `internal/packaging/`.

The core never contains:

- concrete organization or tenant values;
- credentials, tokens, private keys, or authorization headers;
- live state, plans, or variable binding files (`*.tfstate`, `*.tfvars`).

## Toolchain

Infrastructure as code is written in HCL and executed exclusively with
OpenTofu. The engine and every provider are exactly pinned, provider GPG
validation is enforced, and lock files of the foundation areas and the
hosting-platform projection areas stay local. The OpenTofu toolchain
provisioning and gates are owned by the `opentofu` capability pack, declared
through the `extends` list of the quality configuration seam; the pack
contract lives in the shared-kernel registry under
`capabilities/infrastructure/opentofu/`.

## Quality gates

```text
gofmt
go test ./...
go tool -modfile tools/go.mod check-coverage
go tool -modfile tools/go.mod quality-gate
```

Every executable Go package must reach exactly 100.0% statement coverage.
`quality-gate` runs the canonical gate chain of the go-quality-authority
territory home through the pinned tooling module: Go formatting, module
checksums and metadata, the pinned build tool module, lint (staticcheck), unit
tests, exact 100% statement coverage, race detector, static analysis,
fail-closed vulnerability analysis (govulncheck), and Lefthook configuration
validation. The OpenTofu gates — engine version verification, recursive format
check, and `init` plus `validate` for every foundation area and projection
area with enforced provider GPG validation — are owned by the `opentofu`
capability pack and run in the canonical quality lane.

The CI surface is the canonical thin callers of the repository-governance
home (`ci.yml`, `codeql.yml`, `dependency-review.yml`) plus the
`canonical-conformance.yml` lane, which proves the bindings of this
repository against the home fail-closed. The canonical quality lane
provisions the declared capability packs before the gate runs.

The Go toolchain is pinned exactly (`toolchain go1.26.6`,
`GOTOOLCHAIN=local`); no lane downloads a toolchain at build time. Build tools
live in the pinned `tools/` module. CI re-runs the full gate daily so newly
disclosed vulnerabilities fail closed even without source changes.

## Repository layout

- `organization/`, `folders/`, `identity-baseline/`, `kms/`, `logging/`,
  `network/` and `policy/` are the seven substrate foundation areas;
  `hosting-platforms/github/custom-properties/` and
  `hosting-platforms/github/rulesets/` are the hosting-platform projection
  areas.
- `internal/packaging/` contains the same-package workflow contract tests.
- `docs/` contains architecture, conventions, and development
  documentation.
- `repo-bindings.json` is the tenant binding manifest of the canonical
  adoption: the home pin, the caller hashes, the canonical file bindings, and
  the config-seam and tooling-module pins.

## Governance

Governed changes land through ticket branches and pull requests into
`develop`. `main` is the production and control-plane truth. Branch
governance is bound through the organization-level rule-sets; see
`docs/conventions/hosting-plattform/github/rule-sets/` for the canonical
source and the rule-set family of this repository.
