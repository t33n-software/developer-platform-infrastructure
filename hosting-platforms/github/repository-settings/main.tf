// GitHub repository-settings projection of the developer platform
// infrastructure core. Target values arrive exclusively through the module
// inputs; the module never carries an organization value. Repositories are
// adopted by the consuming root, never created here.

resource "github_repository" "settings" {
  for_each = var.repository_settings

  name                   = each.key
  allow_rebase_merge     = each.value.allow_rebase_merge
  delete_branch_on_merge = each.value.delete_branch_on_merge

  lifecycle {
    ignore_changes = [
      allow_auto_merge,
      allow_merge_commit,
      allow_squash_merge,
      allow_update_branch,
      archive_on_destroy,
      archived,
      auto_init,
      description,
      gitignore_template,
      has_discussions,
      has_downloads,
      has_issues,
      has_projects,
      has_wiki,
      homepage_url,
      is_template,
      license_template,
      merge_commit_message,
      merge_commit_title,
      squash_merge_commit_message,
      squash_merge_commit_title,
    ]
  }
}