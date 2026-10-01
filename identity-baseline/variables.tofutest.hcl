# The behavioral proof of the identity baseline area variable contract:
# every custom condition of the root is proven with concrete values —
# rejection paths through expect_failures, the acceptance path through
# assertions. No run creates infrastructure: every run is a plan with
# refresh disabled.
#
# The engine key reference is never committed: the encryption block
# resolves it at initialization, so the execution supplies it through the
# instance-bound variable channel (a gitignored *.tfvars in the governed
# execution window). Every value in this file is synthetic test data.

variables {
  # The shared valid identity baseline set every run starts from; a
  # rejection run overrides exactly the value under test.
  identity_baseline_groups = {
    forensics_readers = {
      display_name         = "ops-forensics-readers"
      group_address        = "ops-forensics-readers@example.com"
      parent               = "customers/C0test00000"
      description          = "The dedicated standing read-only forensics identity class of the test organization."
      security             = true
      initial_group_config = "EMPTY"
    }
  }
}

run "accepts_the_valid_identity_baseline_group_set" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = google_cloud_identity_group.groups["forensics_readers"].display_name == "ops-forensics-readers"
    error_message = "The identity baseline group must carry the declared display name."
  }

  assert {
    condition     = google_cloud_identity_group.groups["forensics_readers"].parent == "customers/C0test00000"
    error_message = "The identity baseline group must carry the declared parent."
  }

  assert {
    condition     = google_cloud_identity_group.groups["forensics_readers"].description == "The dedicated standing read-only forensics identity class of the test organization."
    error_message = "The identity baseline group must carry the declared description."
  }

  assert {
    condition     = google_cloud_identity_group.groups["forensics_readers"].initial_group_config == "EMPTY"
    error_message = "The identity baseline group must carry the declared initial group configuration."
  }

  assert {
    condition     = google_cloud_identity_group.groups["forensics_readers"].group_key[0].id == "ops-forensics-readers@example.com"
    error_message = "The identity baseline group must bind the declared group address as its entity key."
  }

  assert {
    condition     = google_cloud_identity_group.groups["forensics_readers"].labels["cloudidentity.googleapis.com/groups.discussion_forum"] == ""
    error_message = "Every identity baseline group must carry the base type label with an empty value, including security groups."
  }

  assert {
    condition     = google_cloud_identity_group.groups["forensics_readers"].labels["cloudidentity.googleapis.com/groups.security"] == ""
    error_message = "The security identity baseline group must carry the security label with an empty value."
  }
}

run "accepts_a_non_security_group_with_the_base_label_only" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    identity_baseline_groups = {
      forensics_readers = {
        display_name         = "ops-forensics-readers"
        group_address        = "ops-forensics-readers@example.com"
        parent               = "customers/C0test00000"
        description          = "The dedicated standing read-only forensics identity class of the test organization."
        security             = false
        initial_group_config = "EMPTY"
      }
    }
  }

  assert {
    condition     = google_cloud_identity_group.groups["forensics_readers"].labels["cloudidentity.googleapis.com/groups.discussion_forum"] == ""
    error_message = "Every identity baseline group must carry the base type label with an empty value."
  }

  assert {
    condition     = !contains(keys(google_cloud_identity_group.groups["forensics_readers"].labels), "cloudidentity.googleapis.com/groups.security")
    error_message = "A non-security identity baseline group must not carry the security label."
  }
}

run "rejects_a_bucket_name_with_invalid_characters" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_bucket_name = "Test-Foundation-State"
  }

  expect_failures = [var.state_bucket_name]
}

run "rejects_a_bucket_name_in_ip_form" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_bucket_name = "192.168.1.1"
  }

  expect_failures = [var.state_bucket_name]
}

run "rejects_a_bucket_name_with_the_goog_prefix" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_bucket_name = "goog-foundation-state"
  }

  expect_failures = [var.state_bucket_name]
}

run "rejects_a_bucket_name_with_the_google_substring" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_bucket_name = "test-google-state"
  }

  expect_failures = [var.state_bucket_name]
}

run "rejects_an_invalid_engine_key_form" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_encryption_key = "not-a-kms-key"
  }

  expect_failures = [var.state_encryption_key]
}

run "rejects_an_empty_identity_baseline_group_map" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    identity_baseline_groups = {}
  }

  expect_failures = [var.identity_baseline_groups]
}

run "rejects_an_empty_display_name" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    identity_baseline_groups = {
      forensics_readers = {
        display_name         = ""
        group_address        = "ops-forensics-readers@example.com"
        parent               = "customers/C0test00000"
        description          = "The dedicated standing read-only forensics identity class of the test organization."
        security             = true
        initial_group_config = "EMPTY"
      }
    }
  }

  expect_failures = [var.identity_baseline_groups]
}

run "rejects_a_malformed_group_address" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    identity_baseline_groups = {
      forensics_readers = {
        display_name         = "ops-forensics-readers"
        group_address        = "ops-forensics-readers"
        parent               = "customers/C0test00000"
        description          = "The dedicated standing read-only forensics identity class of the test organization."
        security             = true
        initial_group_config = "EMPTY"
      }
    }
  }

  expect_failures = [var.identity_baseline_groups]
}

run "rejects_a_malformed_parent_form" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    identity_baseline_groups = {
      forensics_readers = {
        display_name         = "ops-forensics-readers"
        group_address        = "ops-forensics-readers@example.com"
        parent               = "organizations/123456789012"
        description          = "The dedicated standing read-only forensics identity class of the test organization."
        security             = true
        initial_group_config = "EMPTY"
      }
    }
  }

  expect_failures = [var.identity_baseline_groups]
}

run "rejects_an_empty_description" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    identity_baseline_groups = {
      forensics_readers = {
        display_name         = "ops-forensics-readers"
        group_address        = "ops-forensics-readers@example.com"
        parent               = "customers/C0test00000"
        description          = ""
        security             = true
        initial_group_config = "EMPTY"
      }
    }
  }

  expect_failures = [var.identity_baseline_groups]
}

run "rejects_an_oversized_description" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    identity_baseline_groups = {
      forensics_readers = {
        display_name         = "ops-forensics-readers"
        group_address        = "ops-forensics-readers@example.com"
        parent               = "customers/C0test00000"
        description          = "a${join("", [for i in range(1024) : "aaaa"])}"
        security             = true
        initial_group_config = "EMPTY"
      }
    }
  }

  expect_failures = [var.identity_baseline_groups]
}

run "rejects_an_invalid_initial_group_configuration" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    identity_baseline_groups = {
      forensics_readers = {
        display_name         = "ops-forensics-readers"
        group_address        = "ops-forensics-readers@example.com"
        parent               = "customers/C0test00000"
        description          = "The dedicated standing read-only forensics identity class of the test organization."
        security             = true
        initial_group_config = "WITH_INITIAL"
      }
    }
  }

  expect_failures = [var.identity_baseline_groups]
}