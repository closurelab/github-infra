module "labels" {
  source = "../labels"
}

resource "github_repository" "this" {
  name        = var.name
  description = var.description
  visibility  = var.visibility

  auto_init    = false
  has_issues   = var.has_issues
  has_projects = var.has_projects
  has_wiki     = var.has_wiki

  allow_merge_commit        = var.allow_merge_commit
  allow_rebase_merge        = var.allow_rebase_merge
  allow_squash_merge        = var.allow_squash_merge
  delete_branch_on_merge    = var.delete_branch_on_merge
  squash_merge_commit_title = var.squash_merge_commit_title
}

resource "github_branch_default" "this" {
  count = var.manage_default_branch ? 1 : 0

  repository = github_repository.this.name
  branch     = var.default_branch
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
