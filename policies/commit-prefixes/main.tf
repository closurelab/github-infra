variable "gitlint" {
  description = "Contents of the repository's .gitlint configuration."
  type        = string
}

module "labels" {
  source = "../labels"
}

locals {
  values = toset(split(
    "|",
    regex("regex=\\^\\(([^)]+)\\)", var.gitlint)[0],
  ))
}

check "labels" {
  assert {
    condition     = local.values == toset(keys(module.labels.values))
    error_message = "Standard GitHub labels must match the commit prefixes in .gitlint."
  }
}
