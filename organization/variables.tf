// Input variables of the organization area: the organization identifiers,
// the foundation state-home consumption values and the organization IAM
// member surface. The organization instance supplies every concrete value as
// reviewed configuration; the core never presets one.

variable "organization_id" {
  description = "Numeric identifier of the Google Cloud organization node (the organization identity established through Cloud Identity with the verified organization domain). The organization instance supplies this value as reviewed configuration; the core never presets one."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.organization_id))
    error_message = "organization_id must be the numeric organization identifier."
  }
}

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

variable "organization_iam_members" {
  description = <<-EOT
    The engine-managed organization IAM member surface, keyed by binding
    identity: the organization-level bindings of the organization plane. The
    standing interim carrier binding of the organization-plane mutation class
    is the engine-managed surface; its future retirement into the
    just-in-time form runs through the engine. The organization instance
    supplies every concrete value as reviewed configuration; the core never
    presets one.
  EOT
  type = map(object({
    role   = string
    member = string
  }))

  validation {
    condition     = length(var.organization_iam_members) > 0
    error_message = "organization_iam_members must declare at least one binding; the purpose of this area is the engine-managed organization plane."
  }

  validation {
    condition = alltrue([
      for identity, binding in var.organization_iam_members : can(regex("^roles/[^ ]+$", binding.role))
    ])
    error_message = "every organization IAM member binding must carry a fully formed role string (roles/...)."
  }

  validation {
    condition = alltrue([
      for identity, binding in var.organization_iam_members : can(regex("^(user|serviceAccount|group|domain):[^ ]+$", binding.member))
    ])
    error_message = "every organization IAM member binding must carry a fully formed member string (user:, serviceAccount:, group: or domain:)."
  }
}
