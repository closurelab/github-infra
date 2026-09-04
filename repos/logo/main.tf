terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

module "repository" {
  source = "../../policies/repository"

  name        = "logo"
  description = "Self-referential Common Lisp logo generator for closurelab."
  visibility  = "public"

  providers = {
    github = github
  }
}
