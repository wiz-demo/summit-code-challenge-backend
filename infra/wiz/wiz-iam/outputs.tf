output "role_arn" {
  description = "Wiz IAM role ARN. Consumed by the root module's connector_aws.tf via terraform_remote_state."
  value       = module.wiz.role_arn
}

output "role_arn_2" {
  description = "Tenant 2 Wiz IAM role ARN. Consumed by the root module's connector_aws.tf via terraform_remote_state."
  value       = module.wiz_t2.role_arn
}
