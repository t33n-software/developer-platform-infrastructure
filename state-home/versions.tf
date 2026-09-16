terraform {
  required_version = "= 1.12.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 7.44.0"
    }
  }

  # The state backend of this root: its own state lives in the foundation
  # state bucket — the entry of the state-home map keyed exactly
  # "foundation" — which this area provisions through the organization birth
  # path owned by the operating model (the only local-state birth per
  # organization, followed by the backend migration). The state-key grammar
  # prefix identifies exactly this root and nothing else.
  backend "gcs" {
    bucket = var.state_homes["foundation"].bucket_name
    prefix = "state-home"
  }

  # The engine layer of the dual fortress state-encryption standard: every
  # state and plan artifact of this root is client-side encrypted with
  # AES-256-GCM through the organization key management, fail-closed
  # enforced, before it reaches any backend.
  encryption {
    key_provider "gcp_kms" "main" {
      # Instance binding: the concrete engine key never appears in code.
      kms_encryption_key = var.state_encryption_key
      # 32 bytes = AES-256-GCM, the documented maximum of the method.
      key_length = 32
      # Stable metadata identity: a future rename of the provider does not
      # break the readability of already encrypted artifacts.
      encrypted_metadata_alias = "state-encryption"
    }

    method "aes_gcm" "main" {
      keys = key_provider.gcp_kms.main
    }

    state {
      method   = method.aes_gcm.main
      enforced = true # Fail-closed: never an unencrypted state write
    }

    plan {
      method   = method.aes_gcm.main
      enforced = true # Fail-closed: never an unencrypted plan write
    }

    remote_state_data_sources {
      default {
        method = method.aes_gcm.main
      }
    }
  }
}
