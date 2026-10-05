// Input variables of the policy area: the foundation state-home consumption
// values and the organization-level constraint anchors of the destruction
// discipline. The organization instance supplies every concrete value as
// reviewed configuration; the core never presets one.

variable "state_bucket_name" {
  description = "Instance-bound name of the foundation state-home bucket this root consumes as its state backend (provisioned by the state-home area's governed birth path). The organization instance supplies this value as reviewed configuration; the core never presets one."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$", var.state_bucket_name)) && !can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$", var.state_bucket_name)) && !startswith(var.state_bucket_name, "goog") && !can(regex("google", var.state_bucket_name))
    error_message = "state_bucket_name must satisfy the Cloud Storage bucket naming rules: 3-63 characters of lowercase letters, digits, hyphens, underscores and dots, alphanumeric edges, never an IP form, never the goog prefix and never google or similar spellings."
  }
}

variable "state_encryption_key" {
  description = "Instance-bound GCP KMS key reference of the client-side state and plan encryption engine layer (projects/*/locations/*/keyRings/*/cryptoKeys/*). The organization instance supplies this value as reviewed configuration; the core never presets one."
  type        = string

  validation {
    condition     = can(regex("^projects/[^/]+/locations/[^/]+/keyRings/[^/]+/cryptoKeys/[^/]+$", var.state_encryption_key))
    error_message = "state_encryption_key must be a full GCP KMS key resource name."
  }
}

variable "organization_id" {
  description = "Numeric organization identifier of the policy parent: every organization policy is a hierarchy-addressed resource whose name and parent carry the organizations/<id> form. The organization instance supplies this value as reviewed configuration; the core never presets one."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.organization_id))
    error_message = "organization_id must be the numeric Google Cloud organization identifier."
  }
}

variable "minimum_destroy_scheduled_duration" {
  description = "Instance-bound minimum scheduled-destruction duration for newly created keys (constraints/cloudkms.minimumDestroyScheduledDuration): the platform rejects keys created with a shorter scheduled destruction duration than this minimum, preserving the window in which a still-needed key can be restored. The value carries one of the documented closed-set durations."
  type        = string

  validation {
    condition     = can(regex("^(7d|15d|30d|60d|90d|120d)$", var.minimum_destroy_scheduled_duration))
    error_message = "minimum_destroy_scheduled_duration must be one of the documented closed-set durations: 7d, 15d, 30d, 60d, 90d or 120d."
  }
}

variable "disable_before_destroy" {
  description = "Enforce constraints/cloudkms.disableBeforeDestroy on the organization: a key version must be disabled before it can be scheduled for destruction, so the logs can prove that no consumer needs it anymore before the irreversible step. The enforced posture is the instance decision; disabling it is an explicit, reviewable instance decision."
  type        = bool
}
