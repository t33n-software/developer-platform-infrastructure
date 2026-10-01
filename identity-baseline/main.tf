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

  # The platform birth mechanics: the create request carries the Google Group
  # base type label, while the security label is an additional immutable label
  # of an existing group that the platform never accepts in the create request
  # directly — the merge form composes the base type label always and the
  # security label additionally, and the governed engine birth applies them in
  # the platform-proven two-phase sequenced form.
  labels = merge(
    { "cloudidentity.googleapis.com/groups.discussion_forum" = "" },
    each.value.security ? { "cloudidentity.googleapis.com/groups.security" = "" } : {}
  )

  group_key {
    id = each.value.group_address
  }
}
