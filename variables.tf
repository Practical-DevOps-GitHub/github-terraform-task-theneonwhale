variable "github_token" {
  description = "GitHub PAT"
  type        = string
  sensitive   = true
}

variable "repo_owner" {
  description = "GitHub username or org"
  type        = string
}

variable "repo_name" {
  description = "GitHub repository name"
  type        = string
}
