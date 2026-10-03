// Input variables of the logging area: the organization identifiers, the
// foundation state-home consumption values and the organization-plane audit
// export anchor surface. The organization instance supplies every concrete
// value as reviewed configuration; the core never presets one.

variable "organization_id" {
  description = "Numeric identifier of the Google Cloud organization node whose own audit trails the export anchors carry into the evidence boundary. The organization instance supplies this value as reviewed configuration; the core never presets one."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.organization_id))
    error_message = "organization_id must be the numeric organization identifier."
  }
}

variable "state_bucket_name" {
  description = "Instance-bound name of the foundation state-home bucket this root consumes as its state backend (provisioned by the state-home area's governed birth path). The organization instance supplies this value as reviewed configuration; the   core never presets one."
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

variable "organization_audit_export_anchors" {
  description = <<-EOT
    The engine-managed organization-plane audit export anchor surface, keyed
    by anchor name: the routing anchors that carry the organization plane's
    own administrative and data-access audit trails into the evidence
    boundary's immutable retention archive. Every anchor is scoped to the
    organization level itself (never the child projects — the zone audit
    exports of the trust-zone stacks own those), and the engine is the sole
    birth and mutation channel of the anchors. The organization instance
    supplies every concrete value as reviewed configuration; the core never
    presets one.
  EOT

  type = map(object({
    destination = string
    filter      = string
    description = string
    exclusions = optional(list(object({
      name        = string
      filter      = string
      description = optional(string, "")
      disabled    = optional(bool, false)
    })), [])
  }))


  validation {
    condition     = length(var.organization_audit_export_anchors) > 0
    error_message = "organization_audit_export_anchors must declare at least one anchor; the purpose of this area is the engine-managed organization-plane audit export."
  }

  validation {
    condition = alltrue([
      for anchor_name in keys(var.organization_audit_export_anchors) : can(regex("^[A-Za-z0-9]([A-Za-z0-9._-]{0,98}[A-Za-z0-9])$", anchor_name))
    ])
    error_message = "every anchor name must follow the platform identifier grammar: 1-100 characters of letters, digits, underscores, hyphens and periods, beginning and ending with a letter or digit."
  }

  validation {
    condition = alltrue([
      for name, anchor in var.organization_audit_export_anchors : can(regex("^storage\\.googleapis\\.com/[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$", anchor.destination))
    ])
    error_message = "every anchor destination must be the Cloud Storage archive form storage.googleapis.com/<bucket> naming the immutable retention archive bucket; the export target of this area is the evidence boundary's archive, never another sink class."
  }

  validation {
    condition = alltrue([
      for name, anchor in var.organization_audit_export_anchors : length(anchor.filter) > 0
    ])
    error_message = "every anchor must carry a non-empty export filter; the organization instance binds the concrete scope of the export."
  }

  validation {
    condition = alltrue([
      for name, anchor in var.organization_audit_export_anchors : length(anchor.description) > 0 && length(anchor.description) <= 8000
    ])
    error_message = "every anchor must carry a canonical non-empty description of at most 8000 characters."
  }

  validation {
    condition = alltrue([
      for name, anchor in var.organization_audit_export_anchors : alltrue([
        for exclusion in anchor.exclusions : can(regex("^[A-Za-z0-9]([A-Za-z0-9._-]{0,98}[A-Za-z0-9])$", exclusion.name))
      ])
    ])
    error_message = "every exclusion name must follow the platform identifier grammar: 1-100 characters of letters, digits, underscores, hyphens and periods, beginning and ending with a letter or digit."
  }
}
