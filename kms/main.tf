// The organization-wide key management surface of the kms area: the key
// rings, the crypto keys and the key-scoped IAM member bindings every
// platform and trust-zone boundary derives from. The engine is the sole
// birth and mutation channel of these objects — the declaration chain of
// the operator access classes applies to the key surface itself. The area
// creates key rings and keys exclusively through this surface — never by
// hand — and never carries key material: only the ring, key and binding
// references are ever expressed.

resource "google_kms_key_ring" "key_rings" {
  for_each = var.kms_key_rings

  name     = each.key
  location = each.value.location
  project  = each.value.project

  # A key ring is unrecoverable infrastructure: the platform never deletes a
  # key ring, so a destroy would silently unmanage the ring while the live
  # object survives. The fail-closed form blocks the destroy entirely; a
  # retirement runs through the explicit abandon path instead.
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "crypto_keys" {
  for_each = var.kms_crypto_keys

  name     = each.value.name
  key_ring = google_kms_key_ring.key_rings[each.value.key_ring].id
  purpose  = each.value.purpose

  rotation_period            = each.value.rotation_period
  destroy_scheduled_duration = each.value.destroy_scheduled_duration
  labels                     = each.value.labels

  version_template {
    algorithm        = each.value.version_template.algorithm
    protection_level = each.value.version_template.protection_level
  }

  # The destruction of a state-encryption key renders every artifact
  # encrypted with it irrecoverable; the provider-native deletion policy
  # fails the destroy command closed and a retirement runs through the
  # explicit abandon path instead.
  deletion_policy = "PREVENT"
}

resource "google_kms_crypto_key_iam_member" "members" {
  for_each = var.kms_crypto_key_iam_members

  crypto_key_id = google_kms_crypto_key.crypto_keys[each.value.crypto_key].id
  role          = each.value.role
  member        = each.value.member
}
