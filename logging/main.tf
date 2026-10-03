// The organization-plane audit export anchor surface of the logging area:
// the routing anchors that carry the organization plane's own administrative
// and data-access audit trails into the evidence boundary's immutable
// retention archive. The engine is the sole birth and mutation channel of
// these anchors — the declaration chain of the operator access classes
// applies to the anchor surface itself. The area carries never key material,
// credentials or live bindings: only the anchor, destination and filter
// references are ever expressed, and every anchor is scoped to the
// organization level (never the child projects — the zone audit exports of
// the trust-zone stacks own those).

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
