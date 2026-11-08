// Input variables of the custom-properties area: the foundation state-home
// consumption values and the canonical property definitions and repository
// assignments of the organization. The organization instance supplies every
// concrete value as reviewed configuration; the core never presets one.

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

variable "definitions" {
  description = "Custom property definitions keyed by property name, decoded by the caller from the pinned canonical definition artifacts. The module never carries a definition value of its own. default_value mirrors the platform schema: a string for single-value types or a list of strings for multi-value types."
  type = map(object({
    value_type         = string
    required           = optional(bool, false)
    default_value      = optional(any)
    description        = optional(string)
    allowed_values     = optional(list(string))
    values_editable_by = optional(string, "org_actors")
  }))
  nullable = false
}

variable "assignments" {
  description = "Repository custom property values keyed by repository name, then property name. Every value arrives from the organization instance bindings; the module never carries an organization default."
  type        = map(map(string))
  nullable    = false
  default     = {}
}
