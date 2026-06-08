# Same shape as the root module's variables, redeclared here because the
# wiz-iam sub-module has its own provider config and tfstate. Values are
# supplied from the shared infra/wiz/terraform.tfvars (no defaults).

variable "aws_region" {
  description = "AWS region for provider configuration."
  type        = string
}

variable "aws_profile" {
  description = "AWS named profile that maps to the target account."
  type        = string
}

variable "owner" {
  description = "Required `owner` tag (mandatory in this playground account)."
  type        = string
}

variable "wiz_env" {
  description = "Wiz environment to target."
  type        = string
}

variable "wiz_client_id" {
  description = "Wiz service account client ID. Needed for the data.wiz-v2_graphql_query that fetches the tenant ID for the IAM role external-id."
  type        = string
  sensitive   = true
}

variable "wiz_client_secret" {
  description = "Wiz service account client secret."
  type        = string
  sensitive   = true
}

variable "wiz_role_name" {
  description = "Name of the IAM role to create for Wiz to assume."
  type        = string
}

variable "iam_policy_suffix" {
  description = "Suffix appended to Wiz custom IAM policy names to disambiguate from other Wiz deployments in the same account."
  type        = string
}

variable "wiz_remote_arn" {
  description = "Wiz data-center role ARN allowed to assume the customer IAM role. Provided by Wiz."
  type        = string
}
