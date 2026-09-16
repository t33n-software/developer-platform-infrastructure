variable "state_encryption_key" {
  description = "Instance-bound GCP KMS key reference of the client-side state and plan encryption engine layer (projects/*/locations/*/keyRings/*/cryptoKeys/*). The organization instance supplies this value as reviewed configuration; the core never presets one."
  type        = string

  validation {
    condition     = can(regex("^projects/[^/]+/locations/[^/]+/keyRings/[^/]+/cryptoKeys/[^/]+$", var.state_encryption_key))
    error_message = "state_encryption_key must be a full GCP KMS key resource name."
  }
}

variable "state_homes" {
  description = <<-EOT
    The state homes of the organization, keyed by their state-home identity:
    exactly one entry for the foundation (the key is exactly "foundation" —
    this root's own backend joins after the bucket birth and references this
    entry) plus one entry per trust zone. Every entry declares one dedicated
    Cloud Storage bucket holding that boundary's root states and nothing
    else. The organization instance supplies every concrete value as
    reviewed configuration; the core never presets one.
  EOT
  type = map(object({
    project_id       = string
    bucket_name      = string
    location         = string
    cmek_key_name    = string
    operator_members = set(string)
    labels           = map(string)
  }))

  validation {
    condition     = length(var.state_homes) > 0
    error_message = "state_homes must declare at least the foundation state home; the purpose of this area is the state-home declaration."
  }

  validation {
    condition     = contains(keys(var.state_homes), "foundation")
    error_message = "state_homes must carry the entry keyed exactly \"foundation\"; this root's own backend references it."
  }

  validation {
    condition = alltrue([
      for identity, home in var.state_homes : (
        can(regex("^[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$", home.bucket_name))
        && !can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$", home.bucket_name))
        && !startswith(home.bucket_name, "goog")
        && !can(regex("google", home.bucket_name))
      )
    ])
    error_message = "every state home bucket_name must satisfy the Cloud Storage bucket naming rules: 3-63 characters of lowercase letters, digits, hyphens, underscores and dots, alphanumeric edges, never an IP form, never the goog prefix and never google or similar spellings."
  }

  validation {
    condition     = length(distinct([for identity, home in var.state_homes : home.bucket_name])) == length(var.state_homes)
    error_message = "every state home bucket_name must be unique across state_homes; a bucket is never shared across boundaries."
  }

  validation {
    condition = alltrue([
      for identity, home in var.state_homes :
      can(regex("^projects/[^/]+/locations/[^/]+/keyRings/[^/]+/cryptoKeys/[^/]+$", home.cmek_key_name))
    ])
    error_message = "every state home cmek_key_name must be a full GCP KMS key resource name (projects/*/locations/*/keyRings/*/cryptoKeys/*)."
  }

  validation {
    condition = alltrue([
      for identity, home in var.state_homes :
      home.cmek_key_name != var.state_encryption_key
    ])
    error_message = "every state home cmek_key_name must be cryptographically separate from state_encryption_key; the engine key and a bucket CMEK key are disjoint boundaries."
  }

  validation {
    condition = alltrue([
      for identity, home in var.state_homes :
      length(split("/", home.cmek_key_name)) == 8 && element(split("/", home.cmek_key_name), 3) == home.location
    ])
    error_message = "every state home cmek_key_name must reside in the same location as its bucket; the CMEK location coupling is a hard platform rule."
  }

  validation {
    condition = alltrue([
      for identity, home in var.state_homes :
      length(home.operator_members) > 0
      && alltrue([for member in home.operator_members : can(regex("^(user|serviceAccount|group|domain):[^ ]+$", member))])
    ])
    error_message = "every state home must bind at least one operator member, and every member must be a fully formed member string (user:, serviceAccount:, group: or domain:); the bucket data plane is the documented backend credential requirement."
  }
}
