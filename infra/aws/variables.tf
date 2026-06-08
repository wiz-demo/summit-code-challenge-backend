variable "region" {
  type        = string
  description = "AWS region. Must be one of the SCP-allowed regions."
  validation {
    condition     = contains(["us-east-1", "us-east-2", "us-west-2"], var.region)
    error_message = "Region must be us-east-1, us-east-2, or us-west-2 (SCP-allowed)."
  }
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile (SSO) for the target account. Verified via `aws sts get-caller-identity --profile <name>`."
}

variable "owner" {
  type        = string
  description = "Required `owner` tag value. Per CLAUDE.md, mandatory on most resources."
}

variable "project" {
  type        = string
  description = "Project tag for cost attribution."
}

variable "ecs_cluster_name" {
  type        = string
  description = "ECS cluster name."
}

variable "vpc_cidr_by_env" {
  type        = map(string)
  description = "VPC CIDR per environment. Distinct blocks so prod/dev never overlap."
}

variable "environment" {
  type        = string
  description = "Deployment environment. Must be prod or dev. Selects the Terraform workspace, resource-name suffix, and VPC CIDR."
  validation {
    condition     = contains(["prod", "dev"], var.environment)
    error_message = "environment must be \"prod\" or \"dev\"."
  }
}
