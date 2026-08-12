# Developer Platform Infrastructure

`developer-platform-infrastructure` is the organization-agnostic core of the
developer platform foundation modules: organization, folders, identity
baseline, KMS, logging, network, and policy.

This repository never contains concrete organization, tenant, project,
identity, network, secret, or registry bindings. Instances consume these
modules only through exact version pins.

Governed changes land through ticket branches and pull requests into
`develop`. `main` is the production and control-plane truth.
