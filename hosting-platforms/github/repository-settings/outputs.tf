output "projected_repositories" {
  description = "Repository names whose settings are projected by this module."
  value       = keys(github_repository.settings)
}