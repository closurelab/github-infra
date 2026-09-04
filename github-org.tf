module "commit_prefixes" {
  source = "./policies/commit-prefixes"

  gitlint = file("${path.module}/.gitlint")
}

locals {
  repository_files = fileset("${path.module}/repos", "*.json")

  repositories = {
    for repository_file in local.repository_files :
    trimsuffix(repository_file, ".json") => jsondecode(
      file("${path.module}/repos/${repository_file}"),
    )
  }
}

module "repositories" {
  source   = "./policies/repository"
  for_each = local.repositories

  name     = each.key
  settings = each.value

  providers = {
    github = github
  }
}
