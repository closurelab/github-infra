module "commit_prefixes" {
  source = "./policies/commit-prefixes"

  gitlint = file("${path.module}/.gitlint")
}

module "github_infra" {
  source = "./repos/github-infra"

  providers = {
    github = github
  }
}

module "logo" {
  source = "./repos/logo"

  providers = {
    github = github
  }
}
