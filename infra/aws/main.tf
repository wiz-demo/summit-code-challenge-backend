provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = {
      owner       = var.owner
      project     = var.project
      environment = local.environment_tag
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name_suffix = "-061026${var.environment == "prod" ? "" : "-${var.environment}"}"
  # Tag value is the workshop-scoped form (ra-workshop-prod / ra-workshop-dev);
  # var.environment stays prod/dev for workspace, name suffix, and CIDR.
  environment_tag = "ra-workshop-${var.environment}"
  cluster_name    = "${var.ecs_cluster_name}${local.name_suffix}"
  vpc_cidr        = var.vpc_cidr_by_env[var.environment]
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
}
