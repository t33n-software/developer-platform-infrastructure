// The folder hierarchy of the organization plane: the structural grouping
// layer between the organization node and the trust-zone and platform
// projects. The area manages three engine-owned surfaces: the hierarchy
// (google_folder), the folder IAM member surface (google_folder_iam_member)
// and the project placement surface (google_project). The standing interim
// carrier bindings of the folder-plane mutation class are the
// engine-managed surface; their future retirement into the just-in-time form
// runs through the engine on these declared surfaces. The area grants
// folder IAM memberships and project placements exclusively through these
// surfaces — never by hand.
resource "google_folder" "hierarchy" {
  for_each = var.folders

  display_name = each.value.display_name
  parent       = each.value.parent
}

resource "google_folder_iam_member" "plane" {
  for_each = var.folder_iam_members

  folder = google_folder.hierarchy[each.value.folder].name
  role   = each.value.role
  member = each.value.member
}

resource "google_project" "placed" {
  for_each = var.projects

  project_id      = each.value.project_id
  name            = each.value.name
  billing_account = each.value.billing_account
  labels          = each.value.labels

  org_id    = can(regex("^organizations/[0-9]+$", each.value.parent)) ? regex("^organizations/([0-9]+)$", each.value.parent)[0] : null
  folder_id = can(regex("^folders/[0-9]+$", each.value.parent)) ? regex("^folders/([0-9]+)$", each.value.parent)[0] : null
}