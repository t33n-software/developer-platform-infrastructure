variable "repository_settings" {
  description = "Repository settings target values keyed by repository name. Every value arrives from the organization instance bindings; the module never carries an organization default."
  type = map(object({
    allow_rebase_merge     = bool
    delete_branch_on_merge = bool
  }))
  nullable = false
}