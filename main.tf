terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.repo_owner
}

variable "github_token" {}
variable "repo_owner" {}
variable "repo_name" {}

resource "github_repository_collaborator" "add_collaborator" {
  repository = var.repo_name
  username   = "softservedata"
  permission = "push"
}

resource "github_branch" "develop" {
  repository = var.repo_name
  branch     = "develop"
}

resource "github_repository" "update_default_branch" {
  name           = var.repo_name
  default_branch = github_branch.develop.branch
}

resource "github_branch_protection" "develop_protection" {
  repository_id = var.repo_name
  pattern       = "develop"

  required_pull_request_reviews {
    required_approving_review_count = 2
  }
}

resource "github_branch_protection" "main_protection" {
  repository_id = var.repo_name
  pattern       = "main"

  required_pull_request_reviews {
    required_approving_review_count = 1
    require_code_owner_reviews      = true
  }
}

resource "github_repository_file" "pull_request_template" {
  repository = var.repo_name
  file       = ".github/pull_request_template.md"
  content    = file("pull_request_template.md")
  branch     = github_branch.develop.branch
  commit_message = "Add PR template"
}

resource "github_repository_file" "codeowners" {
  repository     = var.repo_name
  file           = ".github/CODEOWNERS"
  content        = "* @softservedata"
  branch         = github_branch.develop.branch
  commit_message = "Add CODEOWNERS"
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = var.repo_name
  title      = "DEPLOY_KEY"
  key        = file("deploy_key.pub")
  read_only  = false
}

resource "github_actions_secret" "discord_webhook" {
  repository = var.repo_name
  secret_name = "DISCORD_WEBHOOK"
  plaintext_value = var.discord_webhook_url
}

resource "github_actions_secret" "pat_secret" {
  repository      = var.repo_name
  secret_name     = "PAT"
  plaintext_value = var.pat
}
