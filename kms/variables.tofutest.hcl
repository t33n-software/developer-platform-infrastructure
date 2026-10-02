# The behavioral proof of the kms area variable contract: every custom
# condition of the root is proven with concrete values — rejection paths
# through expect_failures, the acceptance path through assertions. No run
# creates infrastructure: every run is a plan with refresh disabled.
#
# The engine key reference is never committed: the encryption block
# resolves it at initialization, so the execution supplies it through the
# instance-bound variable channel (a gitignored *.tfvars in the governed
# execution window). Every value in this file is synthetic test data.

variables {
  # The shared valid key management set every run starts from; a rejection
  # run overrides exactly the value under test.
  kms_key_rings = {
    foundation = {
      project  = "example-org-anchor"
      location = "europe-west1"
    }
    zone_control = {
      project  = "example-dep-control"
      location = "europe-west1"
    }
  }
  kms_crypto_keys = {
    "foundation/state-encryption" = {
      key_ring = "foundation"
      name     = "state-encryption"
      purpose  = "ENCRYPT_DECRYPT"
      version_template = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "HSM"
      }
      rotation_period            = "7776000s"
      destroy_scheduled_duration = "10368000s"
    }
    "foundation/state-cmek" = {
      key_ring = "foundation"
      name     = "state-cmek"
      purpose  = "ENCRYPT_DECRYPT"
      version_template = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "HSM"
      }
      rotation_period            = "7776000s"
      destroy_scheduled_duration = "10368000s"
    }
    "zone_control/signing" = {
      key_ring = "zone_control"
      name     = "signing"
      purpose  = "ASYMMETRIC_SIGN"
      version_template = {
        algorithm        = "EC_SIGN_P256_SHA256"
        protection_level = "SOFTWARE"
      }
    }
  }
  kms_crypto_key_iam_members = {
    foundation_state_cmek_service_agent = {
      crypto_key = "foundation/state-cmek"
      role       = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
      member     = "serviceAccount:service-123456789012@gs-project-accounts.iam.gserviceaccount.com"
    }
  }
}

run "accepts_the_valid_key_management_set" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = google_kms_key_ring.key_rings["foundation"].name == "foundation"
    error_message = "The key ring must carry its declared name."
  }

  assert {
    condition     = google_kms_key_ring.key_rings["foundation"].location == "europe-west1"
    error_message = "The key ring must carry the declared location."
  }

  assert {
    condition     = google_kms_key_ring.key_rings["foundation"].project == "example-org-anchor"
    error_message = "The key ring must carry the declared project identifier."
  }

  assert {
    condition     = google_kms_crypto_key.crypto_keys["foundation/state-encryption"].key_ring == google_kms_key_ring.key_rings["foundation"].id
    error_message = "The crypto key must bind the resource ID of its declared key ring."
  }

  assert {
    condition     = google_kms_crypto_key.crypto_keys["foundation/state-encryption"].version_template[0].algorithm == "GOOGLE_SYMMETRIC_ENCRYPTION"
    error_message = "The crypto key must carry the declared version template algorithm."
  }

  assert {
    condition     = google_kms_crypto_key.crypto_keys["foundation/state-encryption"].version_template[0].protection_level == "HSM"
    error_message = "The crypto key must carry the declared version template protection level."
  }

  assert {
    condition     = google_kms_crypto_key.crypto_keys["foundation/state-encryption"].rotation_period == "7776000s"
    error_message = "The crypto key must carry the declared rotation period."
  }

  assert {
    condition     = google_kms_crypto_key.crypto_keys["foundation/state-encryption"].deletion_policy == "PREVENT"
    error_message = "Every crypto key must pin the provider-native deletion policy to the prevent form."
  }

  assert {
    condition     = google_kms_crypto_key.crypto_keys["zone_control/signing"].rotation_period == null
    error_message = "A crypto key without a declared rotation period must carry no rotation schedule."
  }

  assert {
    condition     = google_kms_crypto_key_iam_member.members["foundation_state_cmek_service_agent"].crypto_key_id == google_kms_crypto_key.crypto_keys["foundation/state-cmek"].id
    error_message = "The crypto key IAM member must bind the resource ID of its declared crypto key."
  }

  assert {
    condition     = google_kms_crypto_key_iam_member.members["foundation_state_cmek_service_agent"].role == "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    error_message = "The crypto key IAM member must carry the declared role."
  }
}

run "rejects_an_empty_key_ring_map" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_key_rings = {}
  }

  expect_failures = [var.kms_key_rings]
}

run "rejects_a_malformed_key_ring_name" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_key_rings = {
      "-bad-ring" = {
        project  = "example-org-anchor"
        location = "europe-west1"
      }
    }
  }

  expect_failures = [var.kms_key_rings]
}

run "rejects_a_malformed_key_ring_project" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_key_rings = {
      foundation = {
        project  = "1xample-org-anchor"
        location = "europe-west1"
      }
    }
  }

  expect_failures = [var.kms_key_rings]
}

run "rejects_a_malformed_key_ring_location" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_key_rings = {
      foundation = {
        project  = "example-org-anchor"
        location = "Europe West 1"
      }
    }
  }

  expect_failures = [var.kms_key_rings]
}

run "rejects_an_empty_crypto_key_map" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_keys = {}
  }

  expect_failures = [var.kms_crypto_keys]
}

run "rejects_a_key_identity_outside_the_ring_qualified_form" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_keys = {
      "state-encryption" = {
        key_ring = "foundation"
        name     = "state-encryption"
        purpose  = "ENCRYPT_DECRYPT"
        version_template = {
          algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
          protection_level = "HSM"
        }
      }
    }
  }

  expect_failures = [var.kms_crypto_keys]
}

run "rejects_a_malformed_crypto_key_name" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_keys = {
      "foundation/state-encryption" = {
        key_ring = "foundation"
        name     = "Bad_Name"
        purpose  = "ENCRYPT_DECRYPT"
        version_template = {
          algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
          protection_level = "HSM"
        }
      }
    }
  }

  expect_failures = [var.kms_crypto_keys]
}

run "rejects_an_unknown_key_ring_reference" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_keys = {
      "absent/state-encryption" = {
        key_ring = "absent"
        name     = "state-encryption"
        purpose  = "ENCRYPT_DECRYPT"
        version_template = {
          algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
          protection_level = "HSM"
        }
      }
    }
  }

  expect_failures = [var.kms_crypto_keys]
}

run "rejects_an_invalid_purpose" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_keys = {
      "foundation/state-encryption" = {
        key_ring = "foundation"
        name     = "state-encryption"
        purpose  = "SIGN"
        version_template = {
          algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
          protection_level = "HSM"
        }
      }
    }
  }

  expect_failures = [var.kms_crypto_keys]
}

run "rejects_an_invalid_algorithm" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_keys = {
      "foundation/state-encryption" = {
        key_ring = "foundation"
        name     = "state-encryption"
        purpose  = "ENCRYPT_DECRYPT"
        version_template = {
          algorithm        = "AES256"
          protection_level = "HSM"
        }
      }
    }
  }

  expect_failures = [var.kms_crypto_keys]
}

run "rejects_an_invalid_protection_level" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_keys = {
      "foundation/state-encryption" = {
        key_ring = "foundation"
        name     = "state-encryption"
        purpose  = "ENCRYPT_DECRYPT"
        version_template = {
          algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
          protection_level = "TPM"
        }
      }
    }
  }

  expect_failures = [var.kms_crypto_keys]
}

run "rejects_the_symmetric_algorithm_outside_the_encryption_purpose" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_keys = {
      "zone_control/signing" = {
        key_ring = "zone_control"
        name     = "signing"
        purpose  = "ASYMMETRIC_SIGN"
        version_template = {
          algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
          protection_level = "HSM"
        }
      }
    }
  }

  expect_failures = [var.kms_crypto_keys]
}

run "rejects_a_malformed_rotation_period" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_keys = {
      "foundation/state-encryption" = {
        key_ring = "foundation"
        name     = "state-encryption"
        purpose  = "ENCRYPT_DECRYPT"
        version_template = {
          algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
          protection_level = "HSM"
        }
        rotation_period = "90d"
      }
    }
  }

  expect_failures = [var.kms_crypto_keys]
}

run "rejects_a_rotation_period_of_one_day" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_keys = {
      "foundation/state-encryption" = {
        key_ring = "foundation"
        name     = "state-encryption"
        purpose  = "ENCRYPT_DECRYPT"
        version_template = {
          algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
          protection_level = "HSM"
        }
        rotation_period = "86400s"
      }
    }
  }

  expect_failures = [var.kms_crypto_keys]
}

run "rejects_a_malformed_destroy_scheduled_duration" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_keys = {
      "foundation/state-encryption" = {
        key_ring = "foundation"
        name     = "state-encryption"
        purpose  = "ENCRYPT_DECRYPT"
        version_template = {
          algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
          protection_level = "HSM"
        }
        destroy_scheduled_duration = "120d"
      }
    }
  }

  expect_failures = [var.kms_crypto_keys]
}

run "rejects_an_unknown_crypto_key_reference" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_key_iam_members = {
      absent_member = {
        crypto_key = "foundation/absent"
        role       = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
        member     = "serviceAccount:service-123456789012@gs-project-accounts.iam.gserviceaccount.com"
      }
    }
  }

  expect_failures = [var.kms_crypto_key_iam_members]
}

run "rejects_a_malformed_role" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_key_iam_members = {
      foundation_state_cmek_service_agent = {
        crypto_key = "foundation/state-cmek"
        role       = "cryptoKeyEncrypterDecrypter"
        member     = "serviceAccount:service-123456789012@gs-project-accounts.iam.gserviceaccount.com"
      }
    }
  }

  expect_failures = [var.kms_crypto_key_iam_members]
}

run "rejects_a_malformed_member_string" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    kms_crypto_key_iam_members = {
      foundation_state_cmek_service_agent = {
        crypto_key = "foundation/state-cmek"
        role       = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
        member     = "service-123456789012@gs-project-accounts.iam.gserviceaccount.com"
      }
    }
  }

  expect_failures = [var.kms_crypto_key_iam_members]
}
