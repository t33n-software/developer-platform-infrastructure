// GitHub organization custom-property projection of the developer platform
// infrastructure core. Definitions and assignments arrive exclusively through
// the module inputs; the module never carries an organization value.

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
