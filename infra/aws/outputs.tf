output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "region" {
  value = var.region
}

output "ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "image_uri" {
  value = local.image_uri
}

output "instance_public_ip" {
  description = "Stable Elastic IP of the ECS host. Constant across instance replacement, so the Wiz attack-surface endpoint and its findings persist instead of auto-resolving."
  value       = aws_eip.backend.public_ip
}

output "smoke_test_commands" {
  description = "Curl commands to verify the deploy. Run 'terraform output -raw smoke_test_commands' for an unquoted version."
  value = join("\n", [
    "# sample root",
    "curl -s 'http://${aws_eip.backend.public_ip}:8000/'",
    "",
    "# benign SQLi endpoint",
    "curl -s 'http://${aws_eip.backend.public_ip}:8000/api/users?username=alice'",
    "",
    "# SQL injection exploit (returns all 3 rows)",
    "curl -s --get 'http://${aws_eip.backend.public_ip}:8000/api/users' --data-urlencode \"username=' OR '1'='1\"",
    "",
    "# Command injection",
    "curl -s 'http://${aws_eip.backend.public_ip}:8000/api/execute?command=id'",
  ])
}
