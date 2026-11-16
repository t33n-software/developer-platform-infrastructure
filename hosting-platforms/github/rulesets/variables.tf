variable "review_posture" {
  description = "Declared organization review-capacity posture the projection applies at every import: solo lowers exactly the three review-gate parameters of every payload carrying a pull_request rule (required_approving_review_count to 0, require_code_owner_review and require_last_push_approval to false), because the organization carries no review identity distinct from the author; multi projects every supplied payload value unchanged. The posture is an instance-declared organization fact — never inferred here from environment coordinates or member counts — and an absent or unknown posture fails closed. The canonical ruleset artifacts keep the multi-member target values; the projection is what reproduces the declared posture deterministically at every plan."
  type        = string
  nullable    = false

  validation {
    condition     = var.review_posture == "solo" || var.review_posture == "multi"
    error_message = "review_posture must be exactly solo or multi; the projection fails closed on any other value."
  }
}

variable "rulesets" {
  description = "Organization ruleset payloads keyed by ruleset name, decoded by the caller from the pinned canonical ruleset artifacts. The module never carries a ruleset value of its own. target is branch, tag, or push; enforcement arrives from the caller as active or disabled (evaluate is bound to the Enterprise Cloud entitlement). conditions pair ref_name with exactly one repository selector for branch and tag targets; push targets carry the repository selector without ref_name. bypass_actors arrive from the organization instance bindings; actor_id is omitted for ID-less actor types such as OrganizationAdmin."
  type = map(object({
    target      = string
    enforcement = string
    conditions = object({
      ref_name = optional(object({
        include = list(string)
        exclude = list(string)
      }))
      repository_name = optional(object({
        include   = list(string)
        exclude   = list(string)
        protected = optional(bool, false)
      }))
      repository_id = optional(list(number))
      repository_property = optional(object({
        include = optional(list(object({
          name            = string
          property_values = list(string)
          source          = optional(string, "custom")
        })), [])
        exclude = optional(list(object({
          name            = string
          property_values = list(string)
          source          = optional(string, "custom")
        })), [])
      }))
    })
    rules = object({
      creation                = optional(bool)
      update                  = optional(bool)
      deletion                = optional(bool)
      non_fast_forward        = optional(bool)
      required_linear_history = optional(bool)
      required_signatures     = optional(bool)
      pull_request = optional(object({
        required_approving_review_count   = optional(number, 0)
        dismiss_stale_reviews_on_push     = optional(bool, false)
        require_code_owner_review         = optional(bool, false)
        require_last_push_approval        = optional(bool, false)
        required_review_thread_resolution = optional(bool, false)
        allowed_merge_methods             = list(string)
      }))
      required_status_checks = optional(object({
        strict_required_status_checks_policy = optional(bool, false)
        do_not_enforce_on_create             = optional(bool, false)
        required_check = list(object({
          context        = string
          integration_id = optional(number)
        }))
      }))
      required_workflows = optional(object({
        do_not_enforce_on_create = optional(bool, false)
        required_workflow = list(object({
          repository_id = number
          path          = string
          ref           = optional(string)
        }))
      }))
      required_code_scanning = optional(object({
        required_code_scanning_tool = list(object({
          tool                      = string
          alerts_threshold          = string
          security_alerts_threshold = string
        }))
      }))
      branch_name_pattern = optional(object({
        name     = optional(string)
        operator = string
        pattern  = string
        negate   = optional(bool, false)
      }))
      tag_name_pattern = optional(object({
        name     = optional(string)
        operator = string
        pattern  = string
        negate   = optional(bool, false)
      }))
      commit_author_email_pattern = optional(object({
        name     = optional(string)
        operator = string
        pattern  = string
        negate   = optional(bool, false)
      }))
      commit_message_pattern = optional(object({
        name     = optional(string)
        operator = string
        pattern  = string
        negate   = optional(bool, false)
      }))
      committer_email_pattern = optional(object({
        name     = optional(string)
        operator = string
        pattern  = string
        negate   = optional(bool, false)
      }))
      file_path_restriction = optional(object({
        restricted_file_paths = list(string)
      }))
      file_extension_restriction = optional(object({
        restricted_file_extensions = list(string)
      }))
      max_file_size = optional(object({
        max_file_size = number
      }))
      max_file_path_length = optional(object({
        max_file_path_length = number
      }))
    })
    bypass_actors = optional(list(object({
      actor_id    = optional(number)
      actor_type  = string
      bypass_mode = optional(string, "always")
    })), [])
  }))
  nullable = false
}
