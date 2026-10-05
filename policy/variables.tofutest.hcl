# The behavioral proof of the policy area variable contract: every custom
# condition of the root is proven with concrete values — rejection paths
# through expect_failures, the acceptance path through assertions. No run
# creates infrastructure: every run is a plan with refresh disabled.
#
# The engine key reference is never committed: the encryption block
# resolves it at initialization, so the execution supplies it through the
# instance-bound variable channel (a gitignored *.tfvars in the governed
# execution window). Every value in this file is synthetic test data.

variables {
  organization_id                    = "100000000060"
  minimum_destroy_scheduled_duration = "30d"
  disable_before_destroy             = true
}

run "accepts_the_valid_policy_set" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = google_org_policy_policy.minimum_destroy_scheduled_duration.name == "organizations/100000000060/policies/cloudkms.minimumDestroyScheduledDuration"
    error_message = "The minimum destroy scheduled duration policy must bind the organization-scoped resource name."
  }

  assert {
    condition     = contains(google_org_policy_policy.minimum_destroy_scheduled_duration.spec[0].rules[0].values[0].allowed_values, "in:30d")
    error_message = "The minimum destroy scheduled duration policy must carry the in: prefixed duration value form."
  }

  assert {
    condition     = google_org_policy_policy.disable_before_destroy.name == "organizations/100000000060/policies/cloudkms.disableBeforeDestroy"
    error_message = "The disable before destroy policy must bind the organization-scoped resource name."
  }

  assert {
    condition     = google_org_policy_policy.disable_before_destroy.spec[0].rules[0].enforce == "TRUE"
    error_message = "The disable before destroy policy must pin the enforced posture under the instance-bound true value."
  }

  assert {
    condition     = google_org_policy_policy.minimum_destroy_scheduled_duration.deletion_policy == "PREVENT" && google_org_policy_policy.disable_before_destroy.deletion_policy == "PREVENT"
    error_message = "Every organization policy must pin the provider-native deletion policy to the prevent form: a policy's destruction silently disables its discipline."
  }
}

run "rejects_a_non_numeric_organization_id" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_id = "org-anchor"
  }

  expect_failures = [var.organization_id]
}

run "rejects_a_duration_outside_the_closed_set" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    minimum_destroy_scheduled_duration = "45d"
  }

  expect_failures = [var.minimum_destroy_scheduled_duration]
}