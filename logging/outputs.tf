// Outputs of the logging area: the engine-managed anchor-set audit export
// surface spanning the organization node, the folder grouping layers and
// the hierarchy administration project.

output "organization_audit_export_anchor_ids" {
  description = "Resource IDs of the engine-managed organization-plane audit export anchors, keyed by anchor name."
  value       = { for name, anchor in google_logging_organization_sink.organization_audit_export_anchors : name => anchor.id }
}

output "organization_audit_export_writer_identities" {
  description = "Writer identities of the engine-managed organization-plane audit export anchors, keyed by anchor name — the platform service identities whose standing archive write capability the evidence-store IAM surface declares after the provisioning read-back proves them."
  value       = { for name, anchor in google_logging_organization_sink.organization_audit_export_anchors : name => anchor.writer_identity }
}

output "folder_audit_export_anchor_ids" {
  description = "Resource IDs of the engine-managed folder-level audit export anchors, keyed by anchor name."
  value       = { for name, anchor in google_logging_folder_sink.folder_audit_export_anchors : name => anchor.id }
}

output "folder_audit_export_writer_identities" {
  description = "Writer identities of the engine-managed folder-level audit export anchors, keyed by anchor name — the platform service identities whose standing archive write capability the evidence-store IAM surface declares after the provisioning read-back proves them."
  value       = { for name, anchor in google_logging_folder_sink.folder_audit_export_anchors : name => anchor.writer_identity }
}

output "project_audit_export_anchor_id" {
  description = "Resource ID of the engine-managed project-level audit export anchor of the hierarchy administration project."
  value       = google_logging_project_sink.project_audit_export_anchor.id
}

output "project_audit_export_writer_identity" {
  description = "Writer identity of the engine-managed project-level audit export anchor — the platform service identity whose standing archive write capability the evidence-store IAM surface declares after the provisioning read-back proves it."
  value       = google_logging_project_sink.project_audit_export_anchor.writer_identity
}
