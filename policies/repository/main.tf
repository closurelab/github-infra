module "labels" {
  source = "../labels"
}

resource "github_repository" "this" {
  name        = var.name
  description = var.settings.description
  visibility  = var.settings.visibility

  auto_init    = false
  has_issues   = var.settings.has_issues
  has_projects = var.settings.has_projects
  has_wiki     = var.settings.has_wiki

  allow_merge_commit        = var.settings.allow_merge_commit
  allow_rebase_merge        = var.settings.allow_rebase_merge
  allow_squash_merge        = var.settings.allow_squash_merge
  delete_branch_on_merge    = var.settings.delete_branch_on_merge
  squash_merge_commit_title = var.settings.squash_merge_commit_title
}

resource "github_branch_default" "this" {
  count = var.settings.manage_default_branch ? 1 : 0

  repository = github_repository.this.name
  branch     = var.settings.default_branch
}

resource "github_issue_labels" "this" {
  repository = github_repository.this.name

  dynamic "label" {
    for_each = module.labels.values

    content {
      name        = label.key
      color       = label.value.color
      description = label.value.description
    }
  }
}
