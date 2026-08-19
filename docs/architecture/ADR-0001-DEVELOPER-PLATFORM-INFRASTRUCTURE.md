# ADR-0001: Developer Platform Infrastructure Core

## Status

Accepted

## Context

The federated multi-tenant supply chain architecture requires a developer
platform foundation beneath every bounded context: organization placement,
folder hierarchy, the identity baseline, KMS anchors, audit logging, the
network foundation and organization-level policy. Without an
organization-agnostic foundation core, every organization would re-implement
this substrate and drift from the canonical architecture.

## Decision

This repository is the organization-agnostic developer platform
infrastructure core.

1. It owns the seven canonical substrate foundation areas, each a pinned
   OpenTofu root: `organization/` (the organization node and its placement),
   `folders/` (the folder hierarchy projects are placed under),
   `identity-baseline/` (organization-level identity and access baseline),
   `kms/` (key rings and key references, never key material), `logging/`
   (organization-level audit log routing), `network/` (the shared network
   foundation) and `policy/` (organization policy constraints) — plus the
   hosting-platform projection area
   `hosting-platforms/github/custom-properties/` (the GitHub organization
   custom-property projection: value-free, with definitions decoded from the
   pinned canonical artifacts and assignments supplied by the organization
   instance). Resources land in an area with the first governed
   infrastructure change for that area; the pinned contract and the boundary
   documentation exist from the start.
2. Infrastructure as code is written in HCL and executed exclusively with
   OpenTofu. The engine and every provider are exactly pinned, provider
   GPG validation is enforced everywhere, and every reference stack commits
   its `.terraform.lock.hcl`. The decision rationale lives in
   `docs/conventions/infrastructure-as-code/`.
3. This core never contains concrete organization bindings.
   This core never contains tenant bindings.
   It contains no credentials, tokens, private keys, or authorization
   headers, and no live state, plans, or variable binding files.
4. The `organization/` area documents the organization node as the canonical
   standard. An organization node covers: folder placement of projects, a
   service-perimeter and access-context control plane, organization-wide
   policy constraints, and a central identity and audit boundary. Without an
   organization node these aspects drop out: projects lie flat in the
   account, there is no service perimeter or access context manager, and
   organization-wide policies must be compensated with equivalent
   project-level constraints. Operating without an organization node is
   optionally possible as a documented deviation; the foundation areas keep
   the trust-zone isolation physical, and the deviation plus its
   compensations are recorded in the organization instance. Projects created
   before the organization node are migrated into it later, and the service
   perimeter is retrofitted then.
5. Instances consume this core only through the three-pin consumption
   contract: module version pins for infrastructure, artifact digest pins for
   runtime, and schema version pins for policies and evidence. Instances wire
   the concrete project IDs, regions, OIDC bindings, members and retention
   values as reviewed instance configuration.

## Consequences

- Every foundation area and gate change is a governed, reviewable change
  verified by the source-quality gate: formatting, module integrity, tests,
  exact 100% statement coverage for the Go gates, race detection, static
  analysis, the OpenTofu version gate, recursive `tofu fmt` checks and
  `init` plus `validate` for every foundation area.
- Organization and tenant instances bind the foundation through their own
  reviewed values and prove the binding in their own evidence.
- The core never references a concrete organization or tenant; instances
  reference only the core.
- The `release/*` and `support/*` branch families and their Rulesets are
  activated only with a complete governed release lifecycle.
