# The behavioral proof of the gateway-identity area variable contract: every
# custom condition of the root is proven with concrete values — rejection paths
# through expect_failures, the acceptance path through assertions. No run
# creates infrastructure: every run is a plan with refresh disabled.
#
# The engine key reference is never committed: the encryption block resolves it
# at initialization, so the execution supplies it through the instance-bound
# variable channel (a gitignored *.tfvars in the governed execution window).
# Every value in this file is synthetic test data; the area itself stays
# value-free and carries no concrete organization, project or lane binding.
#
# The plan-phase proof carries every value the plan already knows. The derived
# identity forms (the pool-number-bearing principal set, the provider name and
# service-account email inside the lane variables) are computed attributes;
# their equality proof belongs to the governed window's activation read-backs —
# the house boundary of every encryption-carrying root here.

variables {
  organization         = "synthetic-organization"
  state_bucket_name    = "synthetic-foundation-state"
  state_encryption_key = "projects/synthetic-anchor/locations/europe-west3/keyRings/synthetic-ring/cryptoKeys/synthetic-engine-key"
  gateway_project      = "synthetic-credential-host"
  pool_id              = "synthetic-gateway-pool"

  lanes = {
    synthetic-lane = {
      repository         = "synthetic-organization/synthetic-repository"
      environment        = "synthetic-environment"
      provider_id        = "synthetic-github-provider"
      service_account_id = "synthetic-gateway-identity"
      secret_id          = "AI_GATEWAY_SYNTHETIC_TENANT"
      federation_role    = "roles/iam.workloadIdentityUser"
      accessor_role      = "roles/secretmanager.secretAccessor"
      secret_labels = {
        "owner-repository" = "synthetic-repository"
        "purpose"          = "gateway-credential"
      }
      variable_names = {
        wif_provider    = "SYNTHETIC_WIF_PROVIDER"
        service_account = "SYNTHETIC_SERVICE_ACCOUNT"
        project_id      = "SYNTHETIC_PROJECT_ID"
      }
      can_admins_bypass       = false
      prevent_self_review     = true
      protected_branches_only = true
    }
  }
}

run "binds_one_complete_lane_contract" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = google_iam_workload_identity_pool.gateway.workload_identity_pool_id == "synthetic-gateway-pool" && google_iam_workload_identity_pool.gateway.project == "synthetic-credential-host"
    error_message = "The estate pool is born on the declared credential host project under the declared pool identifier."
  }

  assert {
    condition     = google_iam_workload_identity_pool_provider.gateway["synthetic-lane"].attribute_condition == "assertion.repository_owner == \"synthetic-organization\" && assertion.repository == \"synthetic-organization/synthetic-repository\" && assertion.environment == \"synthetic-environment\""
    error_message = "The provider condition must bind the declared organization, the exact repository and the protected environment: the subject-claim binding of the credential convention is one contract with the declared lane."
  }

  assert {
    condition     = google_iam_workload_identity_pool_provider.gateway["synthetic-lane"].oidc[0].issuer_uri == "https://token.actions.githubusercontent.com"
    error_message = "The lane provider federates the hosting platform's token authority and no other issuer."
  }

  assert {
    condition     = google_iam_workload_identity_pool_provider.gateway["synthetic-lane"].attribute_mapping["attribute.repository"] == "assertion.repository" && google_iam_workload_identity_pool_provider.gateway["synthetic-lane"].attribute_mapping["attribute.environment"] == "assertion.environment"
    error_message = "The attribute mapping must project the repository and environment claims the condition binds on; a condition on an unmapped attribute never holds."
  }

  assert {
    condition     = google_service_account.gateway_lane["synthetic-lane"].account_id == "synthetic-gateway-identity" && google_service_account.gateway_lane["synthetic-lane"].project == "synthetic-credential-host"
    error_message = "The lane's federated workload identity is born on the credential host under the declared account id."
  }

  assert {
    condition     = google_service_account_iam_member.gateway_federation["synthetic-lane"].role == "roles/iam.workloadIdentityUser"
    error_message = "The federation binding carries exactly the instance-declared federation role; the principal-set member form it composes is a computed attribute and is proven by the governed window's activation read-back."
  }

  assert {
    condition     = google_secret_manager_secret_iam_member.gateway_lane_access["synthetic-lane"].secret_id == google_secret_manager_secret.gateway_lane["synthetic-lane"].secret_id && google_secret_manager_secret_iam_member.gateway_lane_access["synthetic-lane"].role == "roles/secretmanager.secretAccessor"
    error_message = "The accessor binding is resource-sharp on the lane's own secret with exactly the accessor role: one secret per lane, never a project-wide surface."
  }

  assert {
    condition     = length(google_secret_manager_secret.gateway_lane["synthetic-lane"].replication[0].auto) == 1 && length(google_secret_manager_secret.gateway_lane["synthetic-lane"].replication[0].auto[0].customer_managed_encryption) == 0
    error_message = "A lane secret without a declared key reference stays on the platform encryption form; the customer-managed block is never half-declared."
  }

  assert {
    condition     = github_actions_environment_variable.gateway_wif_provider["synthetic-lane"].variable_name == "SYNTHETIC_WIF_PROVIDER" && github_actions_environment_variable.gateway_service_account["synthetic-lane"].variable_name == "SYNTHETIC_SERVICE_ACCOUNT" && github_actions_environment_variable.gateway_project_id["synthetic-lane"].variable_name == "SYNTHETIC_PROJECT_ID"
    error_message = "Every lane declares its full three-name variable contract; the name contract is what the lane workflow resolves."
  }

  assert {
    condition     = github_repository_environment.gateway_lane["synthetic-lane"].prevent_self_review == true && github_repository_environment.gateway_lane["synthetic-lane"].can_admins_bypass == false
    error_message = "The protected environment posture arrives from the declared instance values: the review floor of the paid lane is a declaration, never console state."
  }

  assert {
    condition     = length(google_kms_crypto_key_iam_member.gateway_secret_cmek) == 0
    error_message = "The service-agent key authorization exists only for a lane secret that declares a customer-managed key."
  }
}

run "binds_the_customer_managed_secret_form_completely" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {
      synthetic-lane = {
        repository            = "synthetic-organization/synthetic-repository"
        environment           = "synthetic-environment"
        provider_id           = "synthetic-github-provider"
        service_account_id    = "synthetic-gateway-identity"
        secret_id             = "AI_GATEWAY_SYNTHETIC_TENANT"
        federation_role       = "roles/iam.workloadIdentityUser"
        accessor_role         = "roles/secretmanager.secretAccessor"
        secret_cmek_key_name  = "projects/synthetic-anchor/locations/europe-west3/keyRings/synthetic-ring/cryptoKeys/synthetic-secret-key"
        key_authorizer_role   = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
        key_authorizer_member = "serviceAccount:service-123456789012@gcp-sa-secretmanager.iam.gserviceaccount.com"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
    }
  }

  assert {
    condition     = google_secret_manager_secret.gateway_lane["synthetic-lane"].replication[0].auto[0].customer_managed_encryption[0].kms_key_name == "projects/synthetic-anchor/locations/europe-west3/keyRings/synthetic-ring/cryptoKeys/synthetic-secret-key"
    error_message = "A declared customer-managed lane secret must carry its key reference on the encryption form."
  }

  assert {
    condition     = google_kms_crypto_key_iam_member.gateway_secret_cmek["synthetic-lane"].member == "serviceAccount:service-123456789012@gcp-sa-secretmanager.iam.gserviceaccount.com" && google_kms_crypto_key_iam_member.gateway_secret_cmek["synthetic-lane"].role == "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    error_message = "The platform's secret-manager service agent must be authorized on the declared key with the declared role, or the secret's encryption form is declared but unusable."
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

run "rejects_a_malformed_organization" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization = "Synthetic_Org"
  }

  expect_failures = [var.organization]
}

run "rejects_an_organization_with_consecutive_hyphens" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization = "synthetic--organization"
  }

  expect_failures = [var.organization]
}

run "rejects_a_malformed_gateway_project" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    gateway_project = "Synthetic_Host"
  }

  expect_failures = [var.gateway_project]
}

run "rejects_a_too_short_pool_id" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    pool_id = "abc"
  }

  expect_failures = [var.pool_id]
}

run "rejects_the_reserved_gcp_pool_prefix" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    pool_id = "gcp-synthetic-pool"
  }

  expect_failures = [var.pool_id]
}

run "rejects_an_empty_lane_set" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {}
  }

  expect_failures = [var.lanes]
}

run "rejects_a_provider_id_with_an_illegal_character" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {
      synthetic-lane = {
        repository         = "synthetic-organization/synthetic-repository"
        environment        = "synthetic-environment"
        provider_id        = "Synthetic_Provider"
        service_account_id = "synthetic-gateway-identity"
        secret_id          = "AI_GATEWAY_SYNTHETIC_TENANT"
        federation_role    = "roles/iam.workloadIdentityUser"
        accessor_role      = "roles/secretmanager.secretAccessor"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
    }
  }

  expect_failures = [var.lanes]
}

run "rejects_a_service_account_id_beyond_the_documented_length" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {
      synthetic-lane = {
        repository         = "synthetic-organization/synthetic-repository"
        environment        = "synthetic-environment"
        provider_id        = "synthetic-github-provider"
        service_account_id = "synthetic-gateway-identity-name-that-is-far-too-long"
        secret_id          = "AI_GATEWAY_SYNTHETIC_TENANT"
        federation_role    = "roles/iam.workloadIdentityUser"
        accessor_role      = "roles/secretmanager.secretAccessor"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
    }
  }

  expect_failures = [var.lanes]
}

run "rejects_a_secret_id_carrying_a_path_character" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {
      synthetic-lane = {
        repository         = "synthetic-organization/synthetic-repository"
        environment        = "synthetic-environment"
        provider_id        = "synthetic-github-provider"
        service_account_id = "synthetic-gateway-identity"
        secret_id          = "AI_GATEWAY/SYNTHETIC_TENANT"
        federation_role    = "roles/iam.workloadIdentityUser"
        accessor_role      = "roles/secretmanager.secretAccessor"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
    }
  }

  expect_failures = [var.lanes]
}

run "rejects_a_repository_without_the_owner_qualification" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {
      synthetic-lane = {
        repository         = "synthetic-repository"
        environment        = "synthetic-environment"
        provider_id        = "synthetic-github-provider"
        service_account_id = "synthetic-gateway-identity"
        secret_id          = "AI_GATEWAY_SYNTHETIC_TENANT"
        federation_role    = "roles/iam.workloadIdentityUser"
        accessor_role      = "roles/secretmanager.secretAccessor"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
    }
  }

  expect_failures = [var.lanes]
}

run "rejects_a_lane_of_a_foreign_organization" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {
      synthetic-lane = {
        repository         = "other-organization/synthetic-repository"
        environment        = "synthetic-environment"
        provider_id        = "synthetic-github-provider"
        service_account_id = "synthetic-gateway-identity"
        secret_id          = "AI_GATEWAY_SYNTHETIC_TENANT"
        federation_role    = "roles/iam.workloadIdentityUser"
        accessor_role      = "roles/secretmanager.secretAccessor"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
    }
  }

  expect_failures = [var.lanes]
}

run "rejects_an_environment_name_carrying_the_import_delimiter" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {
      synthetic-lane = {
        repository         = "synthetic-organization/synthetic-repository"
        environment        = "synthetic:environment"
        provider_id        = "synthetic-github-provider"
        service_account_id = "synthetic-gateway-identity"
        secret_id          = "AI_GATEWAY_SYNTHETIC_TENANT"
        federation_role    = "roles/iam.workloadIdentityUser"
        accessor_role      = "roles/secretmanager.secretAccessor"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
    }
  }

  expect_failures = [var.lanes]
}

run "rejects_a_malformed_role_reference" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {
      synthetic-lane = {
        repository         = "synthetic-organization/synthetic-repository"
        environment        = "synthetic-environment"
        provider_id        = "synthetic-github-provider"
        service_account_id = "synthetic-gateway-identity"
        secret_id          = "AI_GATEWAY_SYNTHETIC_TENANT"
        federation_role    = "roles/iam workloadIdentityUser"
        accessor_role      = "roles/secretmanager.secretAccessor"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
    }
  }

  expect_failures = [var.lanes]
}

run "rejects_a_half_declared_customer_managed_secret" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {
      synthetic-lane = {
        repository           = "synthetic-organization/synthetic-repository"
        environment          = "synthetic-environment"
        provider_id          = "synthetic-github-provider"
        service_account_id   = "synthetic-gateway-identity"
        secret_id            = "AI_GATEWAY_SYNTHETIC_TENANT"
        federation_role      = "roles/iam.workloadIdentityUser"
        accessor_role        = "roles/secretmanager.secretAccessor"
        secret_cmek_key_name = "projects/synthetic-anchor/locations/europe-west3/keyRings/synthetic-ring/cryptoKeys/synthetic-secret-key"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
    }
  }

  expect_failures = [var.lanes]
}

run "rejects_a_partially_declared_lane_variable_contract" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {
      synthetic-lane = {
        repository         = "synthetic-organization/synthetic-repository"
        environment        = "synthetic-environment"
        provider_id        = "synthetic-github-provider"
        service_account_id = "synthetic-gateway-identity"
        secret_id          = "AI_GATEWAY_SYNTHETIC_TENANT"
        federation_role    = "roles/iam.workloadIdentityUser"
        accessor_role      = "roles/secretmanager.secretAccessor"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = ""
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
    }
  }

  expect_failures = [var.lanes]
}

run "rejects_two_lanes_sharing_one_service_account" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {
      synthetic-lane = {
        repository         = "synthetic-organization/synthetic-repository"
        environment        = "synthetic-environment"
        provider_id        = "synthetic-github-provider"
        service_account_id = "synthetic-gateway-identity"
        secret_id          = "AI_GATEWAY_SYNTHETIC_TENANT"
        federation_role    = "roles/iam.workloadIdentityUser"
        accessor_role      = "roles/secretmanager.secretAccessor"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
      synthetic-other-lane = {
        repository         = "synthetic-organization/synthetic-other-repository"
        environment        = "synthetic-environment"
        provider_id        = "synthetic-other-github-provider"
        service_account_id = "synthetic-gateway-identity"
        secret_id          = "AI_GATEWAY_SYNTHETIC_OTHER_TENANT"
        federation_role    = "roles/iam.workloadIdentityUser"
        accessor_role      = "roles/secretmanager.secretAccessor"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
    }
  }

  expect_failures = [var.lanes]
}

run "rejects_two_lanes_sharing_one_secret" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    lanes = {
      synthetic-lane = {
        repository         = "synthetic-organization/synthetic-repository"
        environment        = "synthetic-environment"
        provider_id        = "synthetic-github-provider"
        service_account_id = "synthetic-gateway-identity"
        secret_id          = "AI_GATEWAY_SYNTHETIC_TENANT"
        federation_role    = "roles/iam.workloadIdentityUser"
        accessor_role      = "roles/secretmanager.secretAccessor"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
      synthetic-other-lane = {
        repository         = "synthetic-organization/synthetic-other-repository"
        environment        = "synthetic-environment"
        provider_id        = "synthetic-other-github-provider"
        service_account_id = "synthetic-other-gateway-identity"
        secret_id          = "AI_GATEWAY_SYNTHETIC_TENANT"
        federation_role    = "roles/iam.workloadIdentityUser"
        accessor_role      = "roles/secretmanager.secretAccessor"
        variable_names = {
          wif_provider    = "SYNTHETIC_WIF_PROVIDER"
          service_account = "SYNTHETIC_SERVICE_ACCOUNT"
          project_id      = "SYNTHETIC_PROJECT_ID"
        }
      }
    }
  }

  expect_failures = [var.lanes]
}
