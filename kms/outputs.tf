// Outputs of the kms area: the engine-managed key management surface.

output "kms_key_ring_ids" {
  description = "Resource IDs of the engine-managed key rings, keyed by key ring name."
  value       = { for name, ring in google_kms_key_ring.key_rings : name => ring.id }
}

output "kms_crypto_key_ids" {
  description = "Resource IDs of the engine-managed crypto keys, keyed by the ring-qualified key identity."
  value       = { for identity, key in google_kms_crypto_key.crypto_keys : identity => key.id }
}

output "kms_crypto_key_iam_member_ids" {
  description = "Resource IDs of the engine-managed crypto key IAM member bindings, keyed by the binding identity."
  value       = { for identity, member in google_kms_crypto_key_iam_member.members : identity => member.id }
}
