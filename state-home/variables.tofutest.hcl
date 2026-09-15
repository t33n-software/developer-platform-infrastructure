# The behavioral proof of the state-home variable contract: every custom
# condition of the root is proven with concrete values — rejection paths
# through expect_failures, the acceptance path through assertions. No run
# creates infrastructure: every run is a plan with refresh disabled.
#
# The engine key reference is never committed: the encryption block resolves
# it at initialization, so the execution supplies it through the
# instance-bound variable channel (a gitignored *.tfvars in the governed
# execution window). Every value in this file is synthetic test data.

variables {
  # The shared valid state-home set every run starts from; a rejection run
  # overrides exactly the value under test.
  state_homes = {
    foundation = {
      project_id       = "test-foundation-project"
      bucket_name      = "test-foundation-state"
      location         = "europe-west1"
      cmek_key_name    = "projects/test-foundation-project/locations/europe-west1/keyRings/foundation/cryptoKeys/foundation-state-cmek"
      operator_members = ["user:ops@example.com"]
      labels = {
        boundary = "foundation"
      }
    }
  }
}

run "accepts_the_valid_state_home_set" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = google_storage_bucket.state_homes["foundation"].name == "test-foundation-state"
    error_message = "The foundation state-home bucket must carry the declared name."
  }

  assert {
    condition     = google_storage_bucket.state_homes["foundation"].uniform_bucket_level_access == true
    error_message = "The foundation state-home bucket must carry uniform bucket-level access."
  }

  assert {
    condition     = google_storage_bucket.state_homes["foundation"].public_access_prevention == "enforced"
    error_message = "The foundation state-home bucket must enforce public access prevention."
  }

  assert {
    condition     = google_storage_bucket_iam_member.operators["foundation/user:ops@example.com"].role == "roles/storage.objectAdmin"
    error_message = "The operator binding must carry exactly the object-admin role."
  }

  assert {
    condition     = google_storage_bucket_iam_member.operators["foundation/user:ops@example.com"].member == "user:ops@example.com"
    error_message = "The operator binding must carry the declared member."
  }
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

run "rejects_an_empty_state_home_map" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_homes = {}
  }

  expect_failures = [var.state_homes]
}

run "rejects_a_bucket_name_with_invalid_characters" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_homes = {
      foundation = {
        project_id       = "test-foundation-project"
        bucket_name      = "Test-Foundation-State"
        location         = "europe-west1"
        cmek_key_name    = "projects/test-foundation-project/locations/europe-west1/keyRings/foundation/cryptoKeys/foundation-state-cmek"
        operator_members = ["user:ops@example.com"]
        labels           = { boundary = "foundation" }
      }
    }
  }

  expect_failures = [var.state_homes]
}

run "rejects_a_bucket_name_in_ip_form" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_homes = {
      foundation = {
        project_id       = "test-foundation-project"
        bucket_name      = "192.168.1.1"
        location         = "europe-west1"
        cmek_key_name    = "projects/test-foundation-project/locations/europe-west1/keyRings/foundation/cryptoKeys/foundation-state-cmek"
        operator_members = ["user:ops@example.com"]
        labels           = { boundary = "foundation" }
      }
    }
  }

  expect_failures = [var.state_homes]
}

run "rejects_a_bucket_name_with_the_goog_prefix" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_homes = {
      foundation = {
        project_id       = "test-foundation-project"
        bucket_name      = "goog-foundation-state"
        location         = "europe-west1"
        cmek_key_name    = "projects/test-foundation-project/locations/europe-west1/keyRings/foundation/cryptoKeys/foundation-state-cmek"
        operator_members = ["user:ops@example.com"]
        labels           = { boundary = "foundation" }
      }
    }
  }

  expect_failures = [var.state_homes]
}

run "rejects_a_bucket_name_with_the_google_substring" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_homes = {
      foundation = {
        project_id       = "test-foundation-project"
        bucket_name      = "test-google-state"
        location         = "europe-west1"
        cmek_key_name    = "projects/test-foundation-project/locations/europe-west1/keyRings/foundation/cryptoKeys/foundation-state-cmek"
        operator_members = ["user:ops@example.com"]
        labels           = { boundary = "foundation" }
      }
    }
  }

  expect_failures = [var.state_homes]
}

run "rejects_duplicate_bucket_names" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_homes = {
      foundation = {
        project_id       = "test-foundation-project"
        bucket_name      = "test-shared-state"
        location         = "europe-west1"
        cmek_key_name    = "projects/test-foundation-project/locations/europe-west1/keyRings/foundation/cryptoKeys/foundation-state-cmek"
        operator_members = ["user:ops@example.com"]
        labels           = { boundary = "foundation" }
      }
      zone = {
        project_id       = "test-zone-project"
        bucket_name      = "test-shared-state"
        location         = "europe-west1"
        cmek_key_name    = "projects/test-zone-project/locations/europe-west1/keyRings/zone/cryptoKeys/zone-state-cmek"
        operator_members = ["user:ops@example.com"]
        labels           = { boundary = "zone" }
      }
    }
  }

  expect_failures = [var.state_homes]
}

run "rejects_an_invalid_cmek_key_form" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_homes = {
      foundation = {
        project_id       = "test-foundation-project"
        bucket_name      = "test-foundation-state"
        location         = "europe-west1"
        cmek_key_name    = "not-a-kms-key"
        operator_members = ["user:ops@example.com"]
        labels           = { boundary = "foundation" }
      }
    }
  }

  expect_failures = [var.state_homes]
}

run "rejects_a_cmek_key_equal_to_the_engine_key" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_encryption_key = "projects/test-foundation-project/locations/europe-west1/keyRings/foundation/cryptoKeys/shared"
    state_homes = {
      foundation = {
        project_id       = "test-foundation-project"
        bucket_name      = "test-foundation-state"
        location         = "europe-west1"
        cmek_key_name    = "projects/test-foundation-project/locations/europe-west1/keyRings/foundation/cryptoKeys/shared"
        operator_members = ["user:ops@example.com"]
        labels           = { boundary = "foundation" }
      }
    }
  }

  expect_failures = [var.state_homes]
}

run "rejects_a_cmek_key_in_a_different_location" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_homes = {
      foundation = {
        project_id       = "test-foundation-project"
        bucket_name      = "test-foundation-state"
        location         = "europe-west1"
        cmek_key_name    = "projects/test-foundation-project/locations/europe-west4/keyRings/foundation/cryptoKeys/foundation-state-cmek"
        operator_members = ["user:ops@example.com"]
        labels           = { boundary = "foundation" }
      }
    }
  }

  expect_failures = [var.state_homes]
}

run "rejects_empty_operator_members" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_homes = {
      foundation = {
        project_id       = "test-foundation-project"
        bucket_name      = "test-foundation-state"
        location         = "europe-west1"
        cmek_key_name    = "projects/test-foundation-project/locations/europe-west1/keyRings/foundation/cryptoKeys/foundation-state-cmek"
        operator_members = []
        labels           = { boundary = "foundation" }
      }
    }
  }

  expect_failures = [var.state_homes]
}

run "rejects_a_malformed_operator_member" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    state_homes = {
      foundation = {
        project_id       = "test-foundation-project"
        bucket_name      = "test-foundation-state"
        location         = "europe-west1"
        cmek_key_name    = "projects/test-foundation-project/locations/europe-west1/keyRings/foundation/cryptoKeys/foundation-state-cmek"
        operator_members = ["ops@example.com"]
        labels           = { boundary = "foundation" }
      }
    }
  }

  expect_failures = [var.state_homes]
}
