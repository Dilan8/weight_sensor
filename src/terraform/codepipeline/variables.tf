variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "ecr_repository" {
  type        = string
  description = "Name of the ECR repository"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "dockerhub_username" {
  type      = string
  sensitive = true
}

variable "dockerhub_password" {
  type      = string
  sensitive = true
}