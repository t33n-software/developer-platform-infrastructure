// Outputs of the policy area: the organization-level constraint anchors.

output "policy_ids" {
  description = "Resource IDs of the engine-managed organization policies, keyed by the policy resource identity."
  value = {
    minimum_destroy_scheduled_duration = google_org_policy_policy.minimum_destroy_scheduled_duration.id
    disable_before_destroy             = google_org_policy_policy.disable_before_destroy.id
  }
}
