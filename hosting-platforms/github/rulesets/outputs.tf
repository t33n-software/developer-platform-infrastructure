output "ruleset_ids" {
  description = "Organization ruleset IDs projected by this module, keyed by ruleset name."
  value       = { for name, ruleset in github_organization_ruleset.rulesets : name => ruleset.ruleset_id }
}
