// Outputs of the organization area: the engine-managed organization IAM
// member surface.

output "organization_iam_member_ids" {
  description = "Resource IDs of the engine-managed organization IAM member bindings, keyed by binding identity."
  value       = { for identity, binding in google_organization_iam_member.organization_plane : identity => binding.id }
}

output "organization_iam_member_surface" {
  description = "The declared organization IAM member surface, keyed by binding identity: role and member."
  value = {
    for identity, declared in var.organization_iam_members : identity => {
      role   = declared.role
      member = declared.member
    }
  }
}
