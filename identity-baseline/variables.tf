// Input variables of the identity baseline area: the foundation state-home
// consumption values and the organization-level Cloud Identity group surface.
// The organization instance supplies every concrete value as reviewed
// configuration; the core never presets one.

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

variable "identity_baseline_groups" {
  description = <<-EOT
    The engine-managed organization-level Cloud Identity group surface of the
    identity baseline, keyed by group identity: the group and principal
    structure every zone and platform boundary derives from. The engine is
    the sole birth and mutation channel of the group objects; the membership
    administration stays on the organization identity plane and never
    touches a binding. The organization instance supplies every concrete
    value as reviewed configuration; the core never presets one.
  EOT
  type = map(object({
    display_name         = string
    group_address        = string
    parent               = string
    description          = string
    security             = bool
    initial_group_config = string
  }))

  validation {
    condition     = length(var.identity_baseline_groups) > 0
    error_message = "identity_baseline_groups must declare at least one group; the purpose of this area is the engine-managed identity baseline."
  }

  validation {
    condition = alltrue([
      for name, group in var.identity_baseline_groups : length(group.display_name) > 0
    ])
    error_message = "every identity baseline group must carry a non-empty display name."
  }

  validation {
    condition = alltrue([
      for name, group in var.identity_baseline_groups : can(regex("^[^\\s@]+@[^\\s@]+$", group.group_address))
    ])
    error_message = "every identity baseline group must carry a fully formed group address (the email form of the entity key)."
  }

  validation {
    condition = alltrue([
      for name, group in var.identity_baseline_groups : can(regex("^customers/[A-Za-z0-9]+$", group.parent))
    ])
    error_message = "every identity baseline group must carry its parent in the customers/<customer id> resource form."
  }

  validation {
    condition = alltrue([
      for name, group in var.identity_baseline_groups : length(group.description) > 0 && length(group.description) <= 4096
    ])
    error_message = "every identity baseline group must carry a non-empty description of at most 4096 characters."
  }

  validation {
    condition = alltrue([
      for name, group in var.identity_baseline_groups : can(regex("^(INITIAL_GROUP_CONFIG_UNSPECIFIED|WITH_INITIAL_OWNER|EMPTY)$", group.initial_group_config))
    ])
    error_message = "every identity baseline group must carry one of the documented initial group configuration values (INITIAL_GROUP_CONFIG_UNSPECIFIED, WITH_INITIAL_OWNER or EMPTY)."
  }
}
