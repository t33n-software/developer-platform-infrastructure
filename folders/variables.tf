// Input variables of the folders area: the foundation state-home
// consumption values, the folder hierarchy, the engine-managed folder IAM
// member surface and the project placement surface. The organization
// instance supplies every concrete value as reviewed configuration; the
// core never presets one.

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

variable "folders" {
  description = <<-EOT
    The engine-managed folder hierarchy, keyed by folder identity: the
    structural grouping layer between the organization node and the
    trust-zone and platform projects. The organization instance supplies
    every concrete value as reviewed configuration; the core never presets
    one.
  EOT
  type = map(object({
    display_name = string
    parent       = string
  }))

  validation {
    condition     = length(var.folders) > 0
    error_message = "folders must declare at least one folder; the purpose of this area is the engine-managed folder hierarchy."
  }

  validation {
    condition = alltrue([
      for identity, folder in var.folders : can(regex("^[A-Za-z0-9]([A-Za-z0-9 _-]{0,28}[A-Za-z0-9])?$", folder.display_name))
    ])
    error_message = "every folder must carry the documented display-name grammar: starts and ends with a letter or digit, at most thirty characters of letters, digits, spaces, hyphens and underscores."
  }

  validation {
    condition = alltrue([
      for identity, folder in var.folders : can(regex("^(organizations|folders)/[0-9]+$", folder.parent))
    ])
    error_message = "every folder must carry a fully formed parent resource name (organizations/{id} or folders/{id})."
  }
}

variable "folder_iam_members" {
  description = <<-EOT
    The engine-managed folder IAM member surface, keyed by binding identity:
    the folder-plane bindings, each referencing a folder identity of the
    hierarchy map. The standing interim carrier bindings of the
    folder-plane mutation class are the engine-managed surface; their
    future retirement into the just-in-time form runs through the engine.
    The organization instance supplies every concrete value as reviewed
    configuration; the core never presets one.
  EOT
  type = map(object({
    folder = string
    role   = string
    member = string
  }))

  validation {
    condition     = length(var.folder_iam_members) > 0
    error_message = "folder_iam_members must declare at least one binding; the purpose of this area is the engine-managed folder plane."
  }

  validation {
    condition = alltrue([
      for identity, binding in var.folder_iam_members : can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", binding.folder))
    ])
    error_message = "every folder IAM member binding must reference its folder by a fully formed folder identity of the hierarchy map."
  }

  validation {
    condition = alltrue([
      for identity, binding in var.folder_iam_members : can(regex("^roles/[^ ]+$", binding.role))
    ])
    error_message = "every folder IAM member binding must carry a fully formed role string (roles/...)."
  }

  validation {
    condition = alltrue([
      for identity, binding in var.folder_iam_members : can(regex("^(user|serviceAccount|group|domain):[^ ]+$", binding.member))
    ])
    error_message = "every folder IAM member binding must carry a fully formed member string (user:, serviceAccount:, group: or domain:)."
  }
}

variable "projects" {
  description = <<-EOT
    The engine-managed project placement surface, keyed by project identity:
    the hierarchy edges of the projects under the organization and its
    folders, with the billing reference and the label projection. The
    organization instance supplies every concrete value as reviewed
    configuration; the core never presets one.
  EOT
  type = map(object({
    project_id      = string
    name            = string
    parent          = string
    billing_account = string
    labels          = map(string)
  }))

  validation {
    condition     = length(var.projects) > 0
    error_message = "projects must declare at least one placed project; the purpose of this area is the engine-managed placement surface."
  }

  validation {
    condition = alltrue([
      for identity, project in var.projects : can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", project.project_id))
    ])
    error_message = "every placed project must carry the documented project-id grammar: six to thirty lowercase letters, digits and hyphens, starting with a letter and ending with a letter or digit."
  }

  validation {
    condition = alltrue([
      for identity, project in var.projects : can(regex("^(organizations|folders)/[0-9]+$", project.parent))
    ])
    error_message = "every placed project must carry a fully formed parent resource name (organizations/{id} or folders/{id})."
  }

  validation {
    condition = alltrue([
      for identity, project in var.projects : can(regex("^[0-9A-F]+-[0-9A-F]+-[0-9A-F]+$", project.billing_account))
    ])
    error_message = "every placed project must carry a fully formed billing account identifier (three uppercase hexadecimal segments)."
  }
}