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

  # The create-only platform field: the platform never returns the initial
  # group configuration after birth, so the import state cannot carry it and
  # a declared value would force the replacement (destroy and recreate) of
  # the live object — proven live by the provisioning window's import plan.
  # The birth path still applies the value; imported objects ignore it.
  # Distinct from the description class: that surface is managed and mutable
  # and stays bound to its exact live form.
  lifecycle {
    ignore_changes = [initial_group_config]
  }
}
