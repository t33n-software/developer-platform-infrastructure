// Input variables of the kms area: the foundation state-home consumption
// values and the organization-wide key management surface. The organization
// instance supplies every concrete value as reviewed configuration; the core
// never presets one.

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

variable "kms_key_rings" {
  description = <<-EOT
    The engine-managed key ring surface of the organization, keyed by key
    ring name: the top-level logical groupings the crypto keys of the
    platform and the trust-zone boundaries live in. The engine is the sole
    birth and mutation channel of the key rings; the organization instance
    supplies every concrete value as reviewed configuration; the core never
    presets one.
  EOT
  type = map(object({
    project  = string
    location = string
  }))

  validation {
    condition     = length(var.kms_key_rings) > 0
    error_message = "kms_key_rings must declare at least one key ring; the purpose of this area is the engine-managed key management surface."
  }

  validation {
    condition = alltrue([
      for ring_name in keys(var.kms_key_rings) : can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", ring_name))
    ])
    error_message = "every key ring name must be 1-63 characters of lowercase letters, digits and hyphens with alphanumeric edges."
  }

  validation {
    condition = alltrue([
      for name, ring in var.kms_key_rings : can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", ring.project))
    ])
    error_message = "every key ring must carry a fully formed project identifier: 6-30 characters of lowercase letters, digits and hyphens, beginning with a letter and ending with a letter or digit."
  }

  validation {
    condition = alltrue([
      for name, ring in var.kms_key_rings : can(regex("^[a-z0-9-]+$", ring.location))
    ])
    error_message = "every key ring must carry a fully formed location (a region, a multi-region or global)."
  }
}

variable "kms_crypto_keys" {
  description = <<-EOT
    The engine-managed crypto key surface of the organization, keyed by the
    ring-qualified key identity: every key carries its purpose, its version
    template and its rotation and destruction schedules explicitly. The
    engine is the sole birth and mutation channel of the keys; the
    organization instance supplies every concrete value as reviewed
    configuration; the core never presets one.
  EOT
  type = map(object({
    key_ring = string
    name     = string
    purpose  = string
    version_template = object({
      algorithm        = string
      protection_level = string
    })
    rotation_period            = optional(string)
    destroy_scheduled_duration = optional(string)
    labels                     = optional(map(string))
  }))

  validation {
    condition     = length(var.kms_crypto_keys) > 0
    error_message = "kms_crypto_keys must declare at least one crypto key; the purpose of this area is the engine-managed key management surface."
  }

  validation {
    condition = alltrue([
      for key_identity in keys(var.kms_crypto_keys) : key_identity == format("%s/%s", var.kms_crypto_keys[key_identity].key_ring, var.kms_crypto_keys[key_identity].name)
    ])
    error_message = "every crypto key identity must be the ring-qualified form <key ring>/<key name>."
  }

  validation {
    condition = alltrue([
      for identity, key in var.kms_crypto_keys : can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", key.name))
    ])
    error_message = "every crypto key name must be 1-63 characters of lowercase letters, digits and hyphens with alphanumeric edges."
  }

  validation {
    condition = alltrue([
      for identity, key in var.kms_crypto_keys : contains(keys(var.kms_key_rings), key.key_ring)
    ])
    error_message = "every crypto key must reference a declared key ring; a key ring reference outside the declared ring surface fails closed."
  }

  validation {
    condition = alltrue([
      for identity, key in var.kms_crypto_keys : can(regex("^(ENCRYPT_DECRYPT|ASYMMETRIC_SIGN|ASYMMETRIC_DECRYPT|HMAC)$", key.purpose))
    ])
    error_message = "every crypto key must carry one of the documented purposes: ENCRYPT_DECRYPT, ASYMMETRIC_SIGN, ASYMMETRIC_DECRYPT or HMAC."
  }

  validation {
    condition = alltrue([
      for identity, key in var.kms_crypto_keys : can(regex("^(GOOGLE_SYMMETRIC_ENCRYPTION|EC_SIGN_P256_SHA256|EC_SIGN_P384_SHA384)$", key.version_template.algorithm))
    ])
    error_message = "every crypto key version template must carry one of the documented algorithms: GOOGLE_SYMMETRIC_ENCRYPTION, EC_SIGN_P256_SHA256 or EC_SIGN_P384_SHA384."
  }

  validation {
    condition = alltrue([
      for identity, key in var.kms_crypto_keys : can(regex("^(SOFTWARE|HSM)$", key.version_template.protection_level))
    ])
    error_message = "every crypto key version template must carry one of the documented protection levels: SOFTWARE or HSM."
  }

  validation {
    condition = alltrue([
      for identity, key in var.kms_crypto_keys : (key.purpose == "ENCRYPT_DECRYPT") == (key.version_template.algorithm == "GOOGLE_SYMMETRIC_ENCRYPTION")
    ])
    error_message = "the symmetric algorithm pairs with the ENCRYPT_DECRYPT purpose and every signing algorithm pairs with a signing purpose."
  }

  validation {
    condition = alltrue([
      for identity, key in var.kms_crypto_keys : key.rotation_period == null || (can(regex("^[0-9]+s$", key.rotation_period)) && tonumber(regex("^[0-9]+", key.rotation_period)) > 86400)
    ])
    error_message = "every crypto key rotation period must be the seconds form and greater than a day (86400 seconds)."
  }

  validation {
    condition = alltrue([
      for identity, key in var.kms_crypto_keys : key.destroy_scheduled_duration == null || can(regex("^[0-9]+s$", key.destroy_scheduled_duration))
    ])
    error_message = "every crypto key destruction schedule must be the seconds form."
  }
}

variable "kms_crypto_key_iam_members" {
  description = <<-EOT
    The engine-managed crypto key IAM member surface of the organization,
    keyed by the binding identity: the CMEK service-agent authorizations of
    the state-home buckets and every other key-scoped grant. The engine is
    the sole mutation channel of the key IAM; the organization instance
    supplies every concrete value as reviewed configuration; the core never
    presets one.
  EOT
  type = map(object({
    crypto_key = string
    role       = string
    member     = string
  }))

  validation {
    condition = alltrue([
      for identity, member in var.kms_crypto_key_iam_members : contains(keys(var.kms_crypto_keys), member.crypto_key)
    ])
    error_message = "every crypto key IAM member must reference a declared crypto key; a reference outside the declared key surface fails closed."
  }

  validation {
    condition = alltrue([
      for identity, member in var.kms_crypto_key_iam_members : can(regex("^(roles|organizations/[0-9]+/roles|projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/roles)/[a-zA-Z0-9._-]+$", member.role))
    ])
    error_message = "every crypto key IAM member must carry a fully formed role: a predefined role or an organization- or project-scoped custom role."
  }

  validation {
    condition = alltrue([
      for identity, member in var.kms_crypto_key_iam_members : can(regex("^(user|serviceAccount|group|domain):[^ ]+$", member.member))
    ])
    error_message = "every crypto key IAM member must carry a fully formed member identity."
  }
}
