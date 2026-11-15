# The behavioral proof of the rulesets projection area variable contract and
# the review-posture mapping: every custom condition of the root is proven
# with concrete values — rejection paths through expect_failures, the
# acceptance paths through assertions. No run creates infrastructure: every
# run is a plan with refresh disabled.
#
# Every value in this file is synthetic test data; the area itself stays
# value-free and carries no concrete organization, repository, ruleset name,
# ref pattern or governance value.

variables {
  review_posture = "multi"

  rulesets = {
    "synthetic-governance: shared line" = {
      target      = "branch"
      enforcement = "active"
      conditions = {
        ref_name = {
          include = ["refs/heads/synthetic-line"]
          exclude = []
        }
        repository_name = {
          include = ["~ALL"]
          exclude = []
        }
      }
      rules = {
        deletion         = true
        non_fast_forward = true
        pull_request = {
          required_approving_review_count   = 2
          dismiss_stale_reviews_on_push     = true
          require_code_owner_review         = true
          require_last_push_approval        = true
          required_review_thread_resolution = true
          allowed_merge_methods             = ["merge"]
        }
        required_status_checks = {
          strict_required_status_checks_policy = true
          required_check = [
            { context = "Synthetic lane / Synthetic check" },
          ]
        }
      }
    }
  }
}

run "projects_the_multi_posture_unchanged" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = github_organization_ruleset.rulesets["synthetic-governance: shared line"].rules[0].pull_request[0].required_approving_review_count == 2
    error_message = "The multi posture must project the supplied approving-review count unchanged."
  }

  assert {
    condition     = github_organization_ruleset.rulesets["synthetic-governance: shared line"].rules[0].pull_request[0].require_code_owner_review == true && github_organization_ruleset.rulesets["synthetic-governance: shared line"].rules[0].pull_request[0].require_last_push_approval == true
    error_message = "The multi posture must project the supplied code-owner and last-push review requirements unchanged."
  }

  assert {
    condition     = length([for check in github_organization_ruleset.rulesets["synthetic-governance: shared line"].rules[0].required_status_checks[0].required_check : check.context if check.context == "Synthetic lane / Synthetic check"]) == 1
    error_message = "The posture mapping must never touch a required status check context."
  }
}

run "lowers_the_review_gates_for_the_solo_posture" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    review_posture = "solo"
  }

  assert {
    condition     = github_organization_ruleset.rulesets["synthetic-governance: shared line"].rules[0].pull_request[0].required_approving_review_count == 0
    error_message = "The solo posture must lower the approving-review count to zero at every import."
  }

  assert {
    condition     = github_organization_ruleset.rulesets["synthetic-governance: shared line"].rules[0].pull_request[0].require_code_owner_review == false && github_organization_ruleset.rulesets["synthetic-governance: shared line"].rules[0].pull_request[0].require_last_push_approval == false
    error_message = "The solo posture must lower both code-owner and last-push review requirements at every import."
  }

  assert {
    condition     = github_organization_ruleset.rulesets["synthetic-governance: shared line"].rules[0].pull_request[0].dismiss_stale_reviews_on_push == true && github_organization_ruleset.rulesets["synthetic-governance: shared line"].rules[0].pull_request[0].required_review_thread_resolution == true
    error_message = "The solo posture lowers exactly the three review-gate parameters; every other supplied pull-request value stays unchanged."
  }

  assert {
    condition     = github_organization_ruleset.rulesets["synthetic-governance: shared line"].rules[0].deletion == true && github_organization_ruleset.rulesets["synthetic-governance: shared line"].rules[0].non_fast_forward == true
    error_message = "The solo posture never touches the non-review rules of the pinned artifact."
  }
}

run "passes_a_payload_without_a_pull_request_rule_through" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    review_posture = "solo"
    rulesets = {
      "synthetic-governance: working branches" = {
        target      = "branch"
        enforcement = "active"
        conditions = {
          ref_name = {
            include = ["refs/heads/synthetic-working/*"]
            exclude = []
          }
          repository_name = {
            include = ["~ALL"]
            exclude = []
          }
        }
        rules = {
          non_fast_forward = true
        }
      }
    }
  }

  assert {
    condition     = length(github_organization_ruleset.rulesets["synthetic-governance: working branches"].rules[0].pull_request) == 0
    error_message = "A payload without a pull-request rule must project unchanged under any posture; the mapping never invents a review block."
  }
}

run "rejects_an_unknown_posture" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    review_posture = "team"
  }

  expect_failures = [var.review_posture]
}
