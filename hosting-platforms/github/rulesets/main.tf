// GitHub organization ruleset projection of the developer platform
// infrastructure core. Ruleset payloads arrive exclusively through the module
// input; the module never carries an organization value.

resource "github_organization_ruleset" "rulesets" {
  for_each = var.rulesets

  name        = each.key
  target      = each.value.target
  enforcement = each.value.enforcement

  dynamic "bypass_actors" {
    for_each = each.value.bypass_actors
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  conditions {
    dynamic "ref_name" {
      for_each = each.value.conditions.ref_name == null ? [] : [each.value.conditions.ref_name]
      content {
        include = ref_name.value.include
        exclude = ref_name.value.exclude
      }
    }

    dynamic "repository_name" {
      for_each = each.value.conditions.repository_name == null ? [] : [each.value.conditions.repository_name]
      content {
        include   = repository_name.value.include
        exclude   = repository_name.value.exclude
        protected = repository_name.value.protected
      }
    }

    dynamic "repository_property" {
      for_each = each.value.conditions.repository_property == null ? [] : [each.value.conditions.repository_property]
      content {
        dynamic "include" {
          for_each = repository_property.value.include
          content {
            name            = include.value.name
            property_values = include.value.property_values
            source          = include.value.source
          }
        }
        dynamic "exclude" {
          for_each = repository_property.value.exclude
          content {
            name            = exclude.value.name
            property_values = exclude.value.property_values
            source          = exclude.value.source
          }
        }
      }
    }

    repository_id = each.value.conditions.repository_id
  }

  rules {
    creation                = each.value.rules.creation
    update                  = each.value.rules.update
    deletion                = each.value.rules.deletion
    non_fast_forward        = each.value.rules.non_fast_forward
    required_linear_history = each.value.rules.required_linear_history
    required_signatures     = each.value.rules.required_signatures

    dynamic "pull_request" {
      for_each = each.value.rules.pull_request == null ? [] : [each.value.rules.pull_request]
      content {
        required_approving_review_count   = pull_request.value.required_approving_review_count
        dismiss_stale_reviews_on_push     = pull_request.value.dismiss_stale_reviews_on_push
        require_code_owner_review         = pull_request.value.require_code_owner_review
        require_last_push_approval        = pull_request.value.require_last_push_approval
        required_review_thread_resolution = pull_request.value.required_review_thread_resolution
        allowed_merge_methods             = pull_request.value.allowed_merge_methods
      }
    }

    dynamic "required_status_checks" {
      for_each = each.value.rules.required_status_checks == null ? [] : [each.value.rules.required_status_checks]
      content {
        strict_required_status_checks_policy = required_status_checks.value.strict_required_status_checks_policy
        do_not_enforce_on_create             = required_status_checks.value.do_not_enforce_on_create

        dynamic "required_check" {
          for_each = required_status_checks.value.required_check
          content {
            context        = required_check.value.context
            integration_id = required_check.value.integration_id
          }
        }
      }
    }

    dynamic "required_workflows" {
      for_each = each.value.rules.required_workflows == null ? [] : [each.value.rules.required_workflows]
      content {
        do_not_enforce_on_create = required_workflows.value.do_not_enforce_on_create

        dynamic "required_workflow" {
          for_each = required_workflows.value.required_workflow
          content {
            repository_id = required_workflow.value.repository_id
            path          = required_workflow.value.path
            ref           = required_workflow.value.ref
          }
        }
      }
    }

    dynamic "required_code_scanning" {
      for_each = each.value.rules.required_code_scanning == null ? [] : [each.value.rules.required_code_scanning]
      content {
        dynamic "required_code_scanning_tool" {
          for_each = required_code_scanning.value.required_code_scanning_tool
          content {
            tool                      = required_code_scanning_tool.value.tool
            alerts_threshold          = required_code_scanning_tool.value.alerts_threshold
            security_alerts_threshold = required_code_scanning_tool.value.security_alerts_threshold
          }
        }
      }
    }

    dynamic "branch_name_pattern" {
      for_each = each.value.rules.branch_name_pattern == null ? [] : [each.value.rules.branch_name_pattern]
      content {
        name     = branch_name_pattern.value.name
        operator = branch_name_pattern.value.operator
        pattern  = branch_name_pattern.value.pattern
        negate   = branch_name_pattern.value.negate
      }
    }

    dynamic "tag_name_pattern" {
      for_each = each.value.rules.tag_name_pattern == null ? [] : [each.value.rules.tag_name_pattern]
      content {
        name     = tag_name_pattern.value.name
        operator = tag_name_pattern.value.operator
        pattern  = tag_name_pattern.value.pattern
        negate   = tag_name_pattern.value.negate
      }
    }

    dynamic "commit_author_email_pattern" {
      for_each = each.value.rules.commit_author_email_pattern == null ? [] : [each.value.rules.commit_author_email_pattern]
      content {
        name     = commit_author_email_pattern.value.name
        operator = commit_author_email_pattern.value.operator
        pattern  = commit_author_email_pattern.value.pattern
        negate   = commit_author_email_pattern.value.negate
      }
    }

    dynamic "commit_message_pattern" {
      for_each = each.value.rules.commit_message_pattern == null ? [] : [each.value.rules.commit_message_pattern]
      content {
        name     = commit_message_pattern.value.name
        operator = commit_message_pattern.value.operator
        pattern  = commit_message_pattern.value.pattern
        negate   = commit_message_pattern.value.negate
      }
    }

    dynamic "committer_email_pattern" {
      for_each = each.value.rules.committer_email_pattern == null ? [] : [each.value.rules.committer_email_pattern]
      content {
        name     = committer_email_pattern.value.name
        operator = committer_email_pattern.value.operator
        pattern  = committer_email_pattern.value.pattern
        negate   = committer_email_pattern.value.negate
      }
    }

    dynamic "file_path_restriction" {
      for_each = each.value.rules.file_path_restriction == null ? [] : [each.value.rules.file_path_restriction]
      content {
        restricted_file_paths = file_path_restriction.value.restricted_file_paths
      }
    }

    dynamic "file_extension_restriction" {
      for_each = each.value.rules.file_extension_restriction == null ? [] : [each.value.rules.file_extension_restriction]
      content {
        restricted_file_extensions = file_extension_restriction.value.restricted_file_extensions
      }
    }

    dynamic "max_file_size" {
      for_each = each.value.rules.max_file_size == null ? [] : [each.value.rules.max_file_size]
      content {
        max_file_size = max_file_size.value.max_file_size
      }
    }

    dynamic "max_file_path_length" {
      for_each = each.value.rules.max_file_path_length == null ? [] : [each.value.rules.max_file_path_length]
      content {
        max_file_path_length = max_file_path_length.value.max_file_path_length
      }
    }
  }
}
