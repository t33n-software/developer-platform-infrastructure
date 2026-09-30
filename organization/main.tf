// The organization IAM member surface of the organization plane: the
// engine-managed organization-level bindings. The standing interim carrier
// binding of the organization-plane mutation class (the operator's
// organization administration capability) is the engine-managed surface; its
// future retirement into the just-in-time form runs through the engine on
// this declared surface. The area grants organization IAM memberships
// exclusively through this surface — never by hand.
resource "google_organization_iam_member" "organization_plane" {
  for_each = var.organization_iam_members

  org_id = var.organization_id
  role   = each.value.role
  member = each.value.member
}
