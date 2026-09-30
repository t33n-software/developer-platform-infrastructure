// Outputs of the identity baseline area: the engine-managed Cloud Identity
// group surface.

output "identity_baseline_group_ids" {
  description = "Resource IDs of the engine-managed Cloud Identity group objects, keyed by group identity."
  value       = { for name, group in google_cloud_identity_group.groups : name => group.id }
}

output "identity_baseline_group_surface" {
  description = "The engine-managed Cloud Identity group surface, keyed by group identity: the provider resource name and the group address."
  value = {
    for name, group in google_cloud_identity_group.groups : name => {
      name        = group.name
      group_email = group.group_key[0].id
    }
  }
}
