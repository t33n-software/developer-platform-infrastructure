// Outputs of the folders area: the engine-managed folder hierarchy, the
// folder IAM member surface and the project placement surface.

output "folder_names" {
  description = "Resource names of the engine-managed folders, keyed by folder identity."
  value       = { for identity, folder in google_folder.hierarchy : identity => folder.name }
}

output "folder_iam_member_ids" {
  description = "Resource IDs of the engine-managed folder IAM member bindings, keyed by binding identity."
  value       = { for identity, member in google_folder_iam_member.plane : identity => member.id }
}

output "folder_iam_member_surface" {
  description = "The declared folder IAM member surface, keyed by binding identity: folder, role and member."
  value = {
    for identity, declared in var.folder_iam_members : identity => {
      folder = declared.folder
      role   = declared.role
      member = declared.member
    }
  }
}

output "project_placement_surface" {
  description = "The declared project placement surface, keyed by project identity: project id, parent, billing account and labels."
  value = {
    for identity, placed in var.projects : identity => {
      project_id      = placed.project_id
      parent          = placed.parent
      billing_account = placed.billing_account
      labels          = placed.labels
    }
  }
}