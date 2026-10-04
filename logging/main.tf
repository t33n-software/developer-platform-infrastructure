// The anchor-set audit export surface of the logging area: the routing
// anchors that carry every privileged hierarchy level's administrative and
// data-access audit trails into the evidence boundary's immutable retention
// archive — the organization node, one anchor per folder grouping layer,
// and the hierarchy administration project. The engine is the sole birth
// and mutation channel of these anchors — the declaration chain of the
// operator access classes applies to the anchor surface itself. The area
// carries never key material, credentials or live bindings: only the
// anchor, destination and filter references are ever expressed, and every
// anchor is scoped to its own level (never the child resources — the zone
// audit exports of the trust-zone stacks own those).

resource "google_logging_organization_sink" "organization_audit_export_anchors" {
  for_each = var.organization_audit_export_anchors

  name        = each.key
  org_id      = var.organization_id
  destination = each.value.destination
  filter      = each.value.filter
  description = each.value.description

  # The anchor scope is the organization level itself: the platform exports
  # only the logs relating to the organization when the child inclusion is
  # disabled, so the anchor never duplicates the zone audit exports of the
  # trust-zone stacks.
  include_children = false

  # An audit export anchor is unrecoverable routing: its destruction stops
  # the organization plane's audit trail silently while the live evidence
  # boundary survives. The fail-closed form blocks the destroy entirely; a
  # retirement runs through the explicit abandon path instead.
  deletion_policy = "PREVENT"

  dynamic "exclusions" {
    for_each = each.value.exclusions

    content {
      name        = exclusions.value.name
      filter      = exclusions.value.filter
      description = exclusions.value.description
      disabled    = exclusions.value.disabled
    }
  }
}

resource "google_logging_folder_sink" "folder_audit_export_anchors" {
  for_each = var.folder_audit_export_anchors

  name        = each.key
  folder      = each.value.folder_id
  destination = each.value.destination
  filter      = each.value.filter
  description = each.value.description

  # The anchor scope is the folder level itself: the platform exports only
  # the logs relating to this folder when the child inclusion is disabled,
  # so the anchor never duplicates the audit exports of the child levels
  # (the zone audit exports of the trust-zone stacks own the project-level
  # trails).
  include_children = false

  # An audit export anchor is unrecoverable routing: its destruction stops
  # the folder level's audit trail silently while the live evidence
  # boundary survives. The fail-closed form blocks the destroy entirely; a
  # retirement runs through the explicit abandon path instead.
  deletion_policy = "PREVENT"

  dynamic "exclusions" {
    for_each = each.value.exclusions

    content {
      name        = exclusions.value.name
      filter      = exclusions.value.filter
      description = exclusions.value.description
      disabled    = exclusions.value.disabled
    }
  }
}

resource "google_logging_project_sink" "project_audit_export_anchor" {
  name        = var.project_audit_export_anchor.name
  project     = var.project_audit_export_anchor.project_id
  destination = var.project_audit_export_anchor.destination
  filter      = var.project_audit_export_anchor.filter
  description = var.project_audit_export_anchor.description

  # The per-class writer form: the anchor project's sink routes its audit
  # trail into the evidence archive outside its own project, and the pinned
  # provider documentation requires the unique writer identity for
  # cross-project routing — the project's own logging service agent is the
  # declared export writer of this anchor class.
  unique_writer_identity = true

  # An audit export anchor is unrecoverable routing: its destruction stops
  # the anchor project's audit trail silently while the live evidence
  # boundary survives. The fail-closed form blocks the destroy entirely; a
  # retirement runs through the explicit abandon path instead.
  deletion_policy = "PREVENT"

  dynamic "exclusions" {
    for_each = var.project_audit_export_anchor.exclusions

    content {
      name        = exclusions.value.name
      filter      = exclusions.value.filter
      description = exclusions.value.description
      disabled    = exclusions.value.disabled
    }
  }
}
