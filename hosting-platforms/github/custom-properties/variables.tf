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
