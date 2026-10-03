// Outputs of the logging area: the engine-managed organization-plane audit
// export anchor surface.

output "organization_audit_export_anchor_ids" {
  description = "Resource IDs of the engine-managed organization-plane audit export anchors, keyed by anchor name."
  value       = { for name, anchor in google_logging_organization_sink.organization_audit_export_anchors : name => anchor.id }
}

output "organization_audit_export_writer_identities" {
  description = "Writer identities of the engine-managed organization-plane audit export anchors, keyed by anchor name — the platform service identities whose standing archive write capability the evidence-store IAM surface declares after the provisioning read-back proves them."
  value       = { for name, anchor in google_logging_organization_sink.organization_audit_export_anchors : name => anchor.writer_identity }
}
