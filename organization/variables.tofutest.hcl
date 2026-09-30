# The behavioral proof of the organization area variable contract: every
# custom condition of the root is proven with concrete values — rejection
# paths through expect_failures, the acceptance path through assertions. No
# run creates infrastructure: every run is a plan with refresh disabled.
#
# The engine key reference is never committed: the encryption block resolves
# it at initialization, so the execution supplies it through the
# instance-bound variable channel (a gitignored *.tfvars in the governed
# execution window). Every value in this file is synthetic test data.

variables {
  # The shared valid organization-plane set every run starts from; a
  # rejection run overrides exactly the value under test.
  organization_id = "123456789012"
  organization_iam_members = {
    organization_plane_interim_carrier = {
      role   = "roles/resourcemanager.organizationAdmin"
      member = "user:ops@example.com"
    }
  }
}

run "accepts_the_valid_organization_plane_set" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = google_organization_iam_member.organization_plane["organization_plane_interim_carrier"].org_id == "123456789012"
    error_message = "The organization IAM member binding must carry the declared organization identifier."
  }

  assert {
    condition     = google_organization_iam_member.organization_plane["organization_plane_interim_carrier"].role == "roles/resourcemanager.organizationAdmin"
    error_message = "The organization IAM member binding must carry the declared role."
  }

  assert {
    condition     = google_organization_iam_member.organization_plane["organization_plane_interim_carrier"].member == "user:ops@example.com"
    error_message = "The organization IAM member binding must carry the declared member."
  }
}

run "rejects_a_non_numeric_organization_id" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_id = "not-numeric"
  }

  expect_failures = [var.organization_id]
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

run "rejects_an_empty_organization_iam_member_map" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_iam_members = {}
  }

  expect_failures = [var.organization_iam_members]
}

run "rejects_a_malformed_role_string" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_iam_members = {
      organization_plane_interim_carrier = {
        role   = "organizationAdmin"
        member = "user:ops@example.com"
      }
    }
  }

  expect_failures = [var.organization_iam_members]
}

run "rejects_a_malformed_member_string" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_iam_members = {
      organization_plane_interim_carrier = {
        role   = "roles/resourcemanager.organizationAdmin"
        member = "ops@example.com"
      }
    }
  }

  expect_failures = [var.organization_iam_members]
}
