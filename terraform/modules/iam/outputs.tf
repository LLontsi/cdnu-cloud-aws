# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OUTPUTS - MODULE IAM
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# EC2
output "ec2_role_arn" {
  description = "ARN du rôle EC2"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_role_name" {
  description = "Nom du rôle EC2"
  value       = aws_iam_role.ec2_role.name
}

output "ec2_instance_profile_name" {
  description = "Nom de l'instance profile EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_instance_profile_arn" {
  description = "ARN de l'instance profile EC2"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

# ECS Task Execution
output "ecs_task_execution_role_arn" {
  description = "ARN du rôle ECS Task Execution"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_execution_role_name" {
  description = "Nom du rôle ECS Task Execution"
  value       = aws_iam_role.ecs_task_execution_role.name
}

# ECS Task
output "ecs_task_role_arn" {
  description = "ARN du rôle ECS Task"
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecs_task_role_name" {
  description = "Nom du rôle ECS Task"
  value       = aws_iam_role.ecs_task_role.name
}

# Lambda
output "lambda_role_arn" {
  description = "ARN du rôle Lambda"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_name" {
  description = "Nom du rôle Lambda"
  value       = aws_iam_role.lambda_role.name
}

# CI/CD
output "cicd_role_arn" {
  description = "ARN du rôle CI/CD"
  value       = aws_iam_role.cicd_role.arn
}

output "cicd_role_name" {
  description = "Nom du rôle CI/CD"
  value       = aws_iam_role.cicd_role.name
}

# Developer
output "developer_role_arn" {
  description = "ARN du rôle Développeur"
  value       = aws_iam_role.developer_role.arn
}

# Admin
output "admin_role_arn" {
  description = "ARN du rôle Admin"
  value       = aws_iam_role.admin_role.arn
}
