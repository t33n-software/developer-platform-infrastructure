// The organization-level Cloud Identity group surface of the identity
// baseline: the group and principal structure every zone and platform
// boundary derives from. The engine is the sole birth and mutation channel
// of the group objects — the declaration chain of the operator access
// classes applies to the group object itself — while the membership
// administration stays on the organization identity plane and never
// touches a binding. The area creates groups exclusively through this
// surface — never by hand.
resource "google_cloud_identity_group" "groups" {
  for_each = var.identity_baseline_groups

  display_name         = each.value.display_name
  description          = each.value.description
  parent               = each.value.parent
  initial_group_config = each.value.initial_group_config

  labels = each.value.security ? {
    "cloudidentity.googleapis.com/groups.security" = ""
    } : {
    "cloudidentity.googleapis.com/groups.discussion_forum" = ""
  }

  group_key {
    id = each.value.group_address
  }
}
