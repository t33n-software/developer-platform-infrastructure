# Developer Platform Infrastructure

`developer-platform-infrastructure` is the organization-agnostic core of the
developer platform foundation modules: organization, folders, identity
baseline, KMS, logging, network, policy, and the hosting-platform projection
area for GitHub organization custom properties.

This repository never contains concrete organization, tenant, project,
identity, network, secret, or registry bindings. Instances consume these
modules only through exact version pins.

## Core boundary

The core owns:

- the seven canonical substrate foundation areas `organization/`,
  `folders/`, `identity-baseline/`, `kms/`, `logging/`, `network/` and
  `policy/`, plus the hosting-platform projection area
  `hosting-platforms/github/custom-properties/`, each a pinned OpenTofu root
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
validation is enforced, and reference stacks commit their
`.terraform.lock.hcl`. The decision rationale lives in
`docs/conventions/infrastructure-as-code/`.

## Quality gates

```text
gofmt
go test ./...
go run -mod=readonly ./cmd/check-coverage
go run -mod=readonly ./cmd/build
```

Every executable Go package must reach exactly 100.0% statement coverage.
`cmd/build` additionally enforces lint (staticcheck), fail-closed
vulnerability analysis (govulncheck), Lefthook configuration validation, and
the OpenTofu gates: engine version verification, recursive format check, and
`init` plus `validate` for every foundation area with enforced provider GPG
validation.

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
- `cmd/` contains the build and coverage gates.
- `internal/packaging/` contains the same-package workflow contract tests.
- `docs/` contains architecture, conventions, and development
  documentation.

## Governance

Governed changes land through ticket branches and pull requests into
`develop`. `main` is the production and control-plane truth. Branch
governance is bound through the organization-level rule-sets; see
`docs/conventions/hosting-plattform/github/rule-sets/` for the canonical
source and the rule-set family of this repository.
