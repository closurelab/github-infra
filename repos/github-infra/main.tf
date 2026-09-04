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

  providers = {
    github = github
  }
}
