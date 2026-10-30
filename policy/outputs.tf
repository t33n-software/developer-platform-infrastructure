// Outputs of the policy area: the organization-level constraint anchors and
// the declared enablement state of their enforcement channel.

output "policy_ids" {
  description = "Resource IDs of the engine-managed organization policies, keyed by the policy resource identity."
  value = {
    minimum_destroy_scheduled_duration = google_org_policy_policy.minimum_destroy_scheduled_duration.id
    disable_before_destroy             = google_org_policy_policy.disable_before_destroy.id
  }
}

output "orgpolicy_service_id" {
  description = "Resource ID of the declared organization-policy API enablement on the quota carrier — the enablement precondition of every policy surface of this root."
  value       = google_project_service.orgpolicy_api.id
}
