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

resource "github_repository_collaborator" "collab" {
  repository = var.repo_name
  username   = "softservedata"
  permission = "push"
}

resource "github_branch" "develop" {
  repository = var.repo_name
  branch     = "develop"
}

resource "github_repository" "repo" {
  name           = var.repo_name
  default_branch = github_branch.develop.branch
}

resource "github_branch_protection" "develop" {
  repository     = var.repo_name
  branch         = github_branch.develop.branch
  enforce_admins = true

  required_pull_request_reviews {
    required_approving_review_count = 2
  }
}

resource "github_branch_protection" "main" {
  repository     = var.repo_name
  branch         = "main"
  enforce_admins = true

  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
  }
}
