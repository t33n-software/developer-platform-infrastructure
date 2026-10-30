// The organization-level policy foundation of the policy area: the
// constraint anchors that keep every resource of the organization on the
// governed baseline. The engine is the sole birth and mutation channel of
// these policy surfaces — the declaration chain of the operator access
// classes applies to the policy surface itself. The area creates policies
// exclusively through this surface — never by hand — and carries only
// constraint selections whose concrete values are instance-supplied.
// The execution contract of this root is part of the declaration: the
// organization-policy API is a quota-gated surface, so the quota carrier
// and the API enablement precondition are declared here instead of being
// carried as per-run folklore outside the versioned truth.

# The quota carrier of every provider call of this root: the pinned
# provider sends the user-project attribution only under the override
# posture with a billing project, so the declarative form binds both on
# the provider configuration. The concrete carrier project is
# instance-supplied; the core never presets one.
provider "google" {
  user_project_override = true
  billing_project       = var.quota_project
}

# The enablement precondition of the constraint surface, declared as
# infrastructure: the organization-policy API on the quota carrier. The
# provider-native deletion policy is pinned to PREVENT — disabling the
# API would stop the enforcement channel of every policy of the
# organization silently while the policies survive; a retirement runs
# through the explicit abandon path.
resource "google_project_service" "orgpolicy_api" {
  project                    = var.quota_project
  service                    = "orgpolicy.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false

  deletion_policy = "PREVENT"
}

# The destruction discipline of the organization key management (the state
# encryption reference's key layer): the platform rejects newly created keys
# whose scheduled destruction duration is shorter than the declared minimum,
# so an accidental or hasty destruction loses its irreversibility window.
# The constraint is a value-set form: the single allowed value carries the
# in: prefixed duration from the documented closed set, and the concrete
# minimum is instance-supplied.
resource "google_org_policy_policy" "minimum_destroy_scheduled_duration" {
  name   = "organizations/${var.organization_id}/policies/cloudkms.minimumDestroyScheduledDuration"
  parent = "organizations/${var.organization_id}"

  # The enforcement surface of a discipline: its destruction would stop the
  # discipline silently while the organization survives. The fail-closed
  # form blocks the destroy entirely; a retirement runs through the
  # explicit abandon path instead.
  deletion_policy = "PREVENT"

  spec {
    rules {
      values {
        allowed_values = ["in:${var.minimum_destroy_scheduled_duration}"]
      }
    }
  }

  # The constraint's enforcement channel is the declared organization-policy
  # API: the birth of every policy of this root is ordered behind the
  # service state of its enablement precondition.
  depends_on = [google_project_service.orgpolicy_api]
}

# The disable-first procedure of the same destruction discipline: a key
# version must be disabled before it can be scheduled for destruction, so
# the logs can prove that no consumer needs it anymore before the
# irreversible step. The enforcement posture is instance-supplied; disabling
# it is an explicit, reviewable instance decision.
resource "google_org_policy_policy" "disable_before_destroy" {
  name   = "organizations/${var.organization_id}/policies/cloudkms.disableBeforeDestroy"
  parent = "organizations/${var.organization_id}"

  deletion_policy = "PREVENT"

  spec {
    rules {
      enforce = var.disable_before_destroy ? "TRUE" : "FALSE"
    }
  }

  depends_on = [google_project_service.orgpolicy_api]
}
