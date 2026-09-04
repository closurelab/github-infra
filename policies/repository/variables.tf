variable "name" {
  description = "GitHub repository name."
  type        = string
}

variable "settings" {
  description = "Repository settings loaded from its JSON descriptor."
  type = object({
    description               = optional(string)
    visibility                = optional(string, "private")
    default_branch            = optional(string, "master")
    manage_default_branch     = optional(bool, false)
    has_issues                = optional(bool, true)
    has_projects              = optional(bool, false)
    has_wiki                  = optional(bool, false)
    allow_merge_commit        = optional(bool, false)
    allow_rebase_merge        = optional(bool, false)
    allow_squash_merge        = optional(bool, true)
    squash_merge_commit_title = optional(string, "COMMIT_OR_PR_TITLE")
    delete_branch_on_merge    = optional(bool, true)
  })
  default = {}

  validation {
    condition     = contains(["private", "public"], var.settings.visibility)
    error_message = "Repository visibility must be private or public."
  }

  validation {
    condition = contains(
      ["PR_TITLE", "COMMIT_OR_PR_TITLE"],
      var.settings.squash_merge_commit_title,
    )
    error_message = "Squash merge commit title must be PR_TITLE or COMMIT_OR_PR_TITLE."
  }
}
