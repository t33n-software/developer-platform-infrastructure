# The behavioral proof of the custom-properties area variable contract: every
# custom condition of the root is proven with concrete values — rejection paths
# through expect_failures, the acceptance path through assertions. No run
# creates infrastructure: every run is a plan with refresh disabled.
#
# The engine key reference is never committed: the encryption block resolves it
# at initialization, so the execution supplies it through the instance-bound
# variable channel (a gitignored *.tfvars in the governed execution window).
# Every value in this file is synthetic test data; the area itself stays
# value-free and carries no concrete organization, tenant or class value.

variables {
  state_bucket_name    = "synthetic-foundation-state"
  state_encryption_key = "projects/synthetic-anchor/locations/europe-west3/keyRings/synthetic-ring/cryptoKeys/synthetic-engine-key"

  definitions = {
    synthetic-class = {
      value_type         = "single_select"
      required           = true
      default_value      = "alpha"
      description        = "Synthetic classification partition used only by this behavioral proof."
      allowed_values     = ["alpha", "beta"]
      values_editable_by = "org_actors"
    }
  }

  assignments = {
    synthetic-repository = {
      synthetic-class = "beta"
    }
  }
}

run "accepts_the_valid_projection_set" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = github_organization_custom_properties.definitions["synthetic-class"].property_name == "synthetic-class"
    error_message = "Every supplied definition must project as one organization custom property keyed by its property name."
  }

  assert {
    condition     = github_organization_custom_properties.definitions["synthetic-class"].value_type == "single_select" && contains(github_organization_custom_properties.definitions["synthetic-class"].allowed_values, "beta")
    error_message = "The projected definition must carry the supplied value type and the supplied allowed values."
  }

  assert {
    condition     = github_organization_custom_properties.definitions["synthetic-class"].values_editable_by == "org_actors"
    error_message = "The editability boundary must stay at the organization actor form; the projection never relaxes it."
  }

  assert {
    condition     = github_repository_custom_property.assignments["synthetic-repository/synthetic-class"].property_type == "single_select"
    error_message = "Every assignment must take its property type from the referenced definition, never from a carried literal."
  }

  assert {
    condition     = length(github_repository_custom_property.assignments["synthetic-repository/synthetic-class"].property_value) == 1 && contains(github_repository_custom_property.assignments["synthetic-repository/synthetic-class"].property_value, "beta")
    error_message = "Every supplied repository value must project as the single-element value set the pinned provider exposes for the assignment surface."
  }
}

run "rejects_a_malformed_state_bucket_name" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_bucket_name = "Synthetic_State_99"
  }

  expect_failures = [var.state_bucket_name]
}

run "rejects_an_ip_address_shaped_state_bucket_name" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_bucket_name = "192.168.1.100"
  }

  expect_failures = [var.state_bucket_name]
}

run "rejects_a_goog_prefixed_state_bucket_name" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_bucket_name = "goog-synthetic-state"
  }

  expect_failures = [var.state_bucket_name]
}

run "rejects_a_google_spelled_state_bucket_name" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_bucket_name = "synthetic-google-state"
  }

  expect_failures = [var.state_bucket_name]
}

run "rejects_a_truncated_state_encryption_key" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_encryption_key = "projects/synthetic-anchor/locations/europe-west3/keyRings/synthetic-ring"
  }

  expect_failures = [var.state_encryption_key]
}
