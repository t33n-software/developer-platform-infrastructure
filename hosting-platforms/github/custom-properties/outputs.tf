output "definition_names" {
  description = "Custom property definition names projected by this module."
  value       = keys(github_organization_custom_properties.definitions)
}
