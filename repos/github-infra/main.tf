terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

module "repository" {
  source = "../../policies/repository"

  name        = "github-infra"
  description = "Declarative GitHub organization infrastructure for closurelab."

  # GitHub cannot assign a default branch to an empty repository. Enable this
  # after the initial apply creates the remote and the local master is pushed.
  manage_default_branch = false

  providers = {
    github = github
  }
}
