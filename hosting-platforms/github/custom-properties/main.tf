// GitHub organization custom-property projection of the developer platform
// infrastructure core. Definitions and assignments arrive exclusively through
// the module inputs; the module never carries an organization value.

// The execution contract of this root is part of the declaration (the DPI-33
// precedent): the organization login is the target of every provider call of
// this root, so it is declared as an instance-bound variable instead of being
// carried as per-run environment folklore. A lane identity that can reach more
// than one organization must never be able to silently retarget this
// projection: the declared organization fails closed at plan time when it is
// missing or malformed. The pinned provider documents the organization
// argument as deprecated and removed in a future major release, so the
// declaration binds the forward-compatible owner argument. The execution lane
// supplies the token only — never the GITHUB_OWNER or GITHUB_ORGANIZATION
// environment coordinate, which the pinned provider's precedence places above
// this configuration until its documented bug is fixed — and the plan gate
// read-back of the import IDs is the target verifier. Credentials are never
// declared here: the applying lane's identity authenticates through the
// pinned provider's token channel.
provider "github" {
  owner = var.organization
}

resource "github_organization_custom_properties" "definitions" {
  for_each = var.definitions

  property_name      = each.key
  value_type         = each.value.value_type
  required           = each.value.required
  default_value      = each.value.default_value
  description        = each.value.description
  allowed_values     = each.value.allowed_values
  values_editable_by = each.value.values_editable_by
}

resource "github_repository_custom_property" "assignments" {
  for_each = merge([
    for repository, properties in var.assignments : {
      for property_name, value in properties :
      "${repository}/${property_name}" => {
        repository    = repository
        property_name = property_name
        value         = value
      }
    }
  ]...)

  repository     = each.value.repository
  property_name  = each.value.property_name
  property_type  = var.definitions[each.value.property_name].value_type
  property_value = [each.value.value]

  depends_on = [github_organization_custom_properties.definitions]
}
