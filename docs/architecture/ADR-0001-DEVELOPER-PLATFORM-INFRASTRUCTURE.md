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

1. It owns the eight canonical substrate foundation areas, each a pinned
   OpenTofu root: `organization/` (the organization node and its placement),
   `folders/` (the folder hierarchy projects are placed under),
   `identity-baseline/` (organization-level identity and access baseline),
   `kms/` (key rings and key references, never key material), `logging/`
   (organization-level audit log routing), `network/` (the shared network
   foundation), `policy/` (organization policy constraints) and
   `state-home/` (the engine-state homes of the organization: the
   foundation's own state home and one per trust zone, provisioned by the
   foundation in the dual fortress form) — plus the
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
6. The organization area's first governed infrastructure change (DPI-17)
   lands the area's engine-managed surfaces: the state backend consumption
   (the `gcs` backend block referencing the instance-bound foundation
   state-home bucket with the state-key grammar prefix `organization`, and
   the client-side engine-layer encryption block of the dual fortress
   standard) and the organization IAM member surface
   (`google_organization_iam_member`). The organization plane is
   engine-managed through this member surface: the standing interim carrier
   binding of the organization-plane mutation class is the engine-managed
   surface, and the future retirement of the interim carrier into the
   just-in-time form runs through the engine on this declared surface.
   Organization identifiers, member identities and every concrete value are
   instance-supplied; the core never presets one.
7. The folders area's first governed infrastructure change (DPI-18) lands
   the area's engine-managed surfaces: the state backend consumption (the
   `gcs` backend block referencing the instance-bound foundation state-home
   bucket with the state-key grammar prefix `folders`, and the client-side
   engine-layer encryption block of the dual fortress standard), the folder
   hierarchy surface (`google_folder`), the folder IAM member surface
   (`google_folder_iam_member`) and the project placement surface
   (`google_project`). The folder plane is engine-managed through these
   surfaces: the standing interim carrier bindings of the folder-plane
   mutation class are the engine-managed surface, and the future retirement
   of the interim carriers into the just-in-time form runs through the
   engine on the declared surfaces. Folder names, parents, placements,
   project identifiers, billing references and every concrete value are
   instance-supplied; the core never presets one.
8. The identity baseline area's first governed infrastructure change (DPI-19)
   lands the area's engine-managed surfaces: the state backend consumption
   (the `gcs` backend block referencing the instance-bound foundation
   state-home bucket with the state-key grammar prefix `identity-baseline`,
   and the client-side engine-layer encryption block of the dual fortress
   standard) and the organization-level Cloud Identity group surface
   (`google_cloud_identity_group`: the group and principal structure every
   zone and platform boundary derives from). The engine is the sole birth
   and mutation channel of the group objects — the declaration chain of the
   operator access classes applies to the group object itself — while the
    membership administration stays on the organization identity plane and
    never touches a binding. The platform's group birth mechanics govern the
    label surface (DPI-21): the create request carries the Google Group base
    type label (`cloudidentity.googleapis.com/groups.discussion_forum`) — the
    default group type — while the security label
    (`cloudidentity.googleapis.com/groups.security`) is an additional
    immutable label of an existing group: the platform rejects its direct
    specification in the create request with the documented 400, and once
    added it can never be removed — the one-way ratchet is a
    platform-enforced fortress invariant, so the access control class cannot
    be silently downgraded. The declaration therefore composes the base type
    label always and the security label additionally through the merge form,
    and the governed engine birth applies them in the platform-proven
    two-phase sequenced form (phase 1: the base-label create; phase 2: the
    immutable security addition through the engine's update); the offline
    verification cannot prove the platform's create semantics — the live
    plan-gated apply is the behavioral verifier. The import path of an existing
    live group object is the plan-gated declarative import block, and the
    platform never returns the initial group configuration after birth — the
    import state cannot carry it, so the declaration carries the lifecycle
    ignore-changes form for exactly that field (DPI-23): the birth path still
    applies it, imported objects ignore it, and the form is never a general
    ignore-changes license. Group addresses, display
    names, descriptions, parents, security types, initial configurations
    and every concrete value are instance-supplied; the core never presets
    one.
 9. The kms area's first governed infrastructure change (DPI-25) lands the
    area's engine-managed surfaces: the state backend consumption (the
    `gcs` backend block referencing the instance-bound foundation state-home
    bucket with the state-key grammar prefix `kms`, and the client-side
    engine-layer encryption block of the dual fortress standard), the
    engine-managed key ring surface (`google_kms_key_ring`: the top-level
    logical groupings with the fail-closed prevent-destroy lifecycle — the
    platform never deletes a key ring, so a destroy would silently unmanage
    the ring while the live object survives), the engine-managed crypto key
    surface (`google_kms_crypto_key`: the purpose, the version template and
    the rotation and destruction schedules explicit per key, with the
    provider-native deletion policy pinned to PREVENT — the destruction of
    a state-encryption key renders every artifact encrypted with it
    irrecoverable, so a retirement runs through the explicit abandon path)
    and the engine-managed crypto key IAM member surface
    (`google_kms_crypto_key_iam_member`: the CMEK service-agent
    authorizations of the state-home buckets and every other key-scoped
    grant). The pinned provider carries no next-rotation-time argument: the
    platform owns the rotation schedule, so no declared field can drift
    against it. Key ring names, projects, locations, key names, purposes,
    algorithms, protection levels, schedules, labels, roles, members and
    every concrete value are instance-supplied; the core never presets
    one.

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
