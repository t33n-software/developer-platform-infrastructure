# Behavioral proof of the gateway-identity channel identity: the declared
# machine identity (GitHub App slug + installation id) of the
# infrastructure-apply class, its per-lane installation selection, and the
# fail-closed validation of the channel coordinate itself. The channel birth
# stays human-gated (the class law); this root declares the channel identity
# and its installation boundary, so the window proves the binding instead of
# a console state.

variables {
  organization         = "synthetic-organization"
  state_bucket_name    = "synthetic-foundation-state"
  state_encryption_key = "projects/synthetic-anchor/locations/europe-west3/keyRings/synthetic-ring/cryptoKeys/synthetic-engine-key"
  gateway_project      = "synthetic-credential-host"
  pool_id              = "synthetic-gateway-pool"

  channel = {
    app_slug        = "synthetic-gateway-channel"
    installation_id = "1234567"
  }

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
  }
}

run "binds_the_channel_installation_per_lane" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = github_app_installation_repository.gateway_lane_channel["synthetic-lane"].installation_id == "1234567"
    error_message = "Every lane carries its installation selection under the declared channel installation id: the approval boundary of the channel identity is declared, never console state."
  }

  assert {
    condition     = github_app_installation_repository.gateway_lane_channel["synthetic-lane"].repository == "synthetic-repository"
    error_message = "The installation selection binds exactly the lane repository the declaration names."
  }
}

run "rejects_a_malformed_channel_app_slug" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    channel = {
      app_slug        = "Synthetic_Channel"
      installation_id = "1234567"
    }
  }

  expect_failures = [var.channel]
}

run "rejects_a_non_numeric_installation_id" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    channel = {
      app_slug        = "synthetic-gateway-channel"
      installation_id = "not-a-number"
    }
  }

  expect_failures = [var.channel]
}

run "rejects_a_channel_without_the_installation_coordinate" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    channel = {
      app_slug        = "synthetic-gateway-channel"
      installation_id = ""
    }
  }

  expect_failures = [var.channel]
}
