variable "name" {
  description = "GitHub repository name."
  type        = string
}

variable "description" {
  description = "GitHub repository description."
  type        = string
  default     = null
}

variable "visibility" {
  description = "GitHub repository visibility."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "public"], var.visibility)
    error_message = "Repository visibility must be private or public."
  }
}

variable "default_branch" {
  description = "Repository default branch."
  type        = string
  default     = "master"
}

variable "manage_default_branch" {
  description = "Whether OpenTofu should manage this repository's existing default branch."
  type        = bool
  default     = false
}

variable "has_issues" {
  description = "Whether GitHub Issues is enabled."
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "Whether GitHub Projects is enabled."
  type        = bool
  default     = false
}

variable "has_wiki" {
  description = "Whether the GitHub wiki is enabled."
  type        = bool
  default     = false
}

variable "allow_merge_commit" {
  description = "Whether pull requests may create merge commits."
  type        = bool
  default     = false
}

variable "allow_rebase_merge" {
  description = "Whether pull requests may use rebase merging."
  type        = bool
  default     = false
}

variable "allow_squash_merge" {
  description = "Whether pull requests may use squash merging."
  type        = bool
  default     = true
}

variable "squash_merge_commit_title" {
  description = "Default title used for squash merge commits."
  type        = string
  default     = "PR_TITLE"

  validation {
    condition = contains(
      ["PR_TITLE", "COMMIT_OR_PR_TITLE"],
      var.squash_merge_commit_title,
    )
    error_message = "Squash merge commit title must be PR_TITLE or COMMIT_OR_PR_TITLE."
  }
}

variable "delete_branch_on_merge" {
  description = "Whether head branches are deleted after pull requests merge."
  type        = bool
  default     = true
}
