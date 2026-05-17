# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OUTPUTS - MODULE API
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ECS Cluster
output "ecs_cluster_id" {
  description = "ID du cluster ECS"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_arn" {
  description = "ARN du cluster ECS"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_cluster_name" {
  description = "Nom du cluster ECS"
  value       = aws_ecs_cluster.main.name
}

# ECS Service
output "ecs_service_name" {
  description = "Nom du service ECS"
  value       = aws_ecs_service.api.name
}

output "ecs_service_id" {
  description = "ID du service ECS"
  value       = aws_ecs_service.api.id
}

# Task Definition
output "task_definition_arn" {
  description = "ARN de la task definition"
  value       = aws_ecs_task_definition.api.arn
}

output "task_definition_family" {
  description = "Family de la task definition"
  value       = aws_ecs_task_definition.api.family
}

# Application Load Balancer
output "alb_dns_name" {
  description = "DNS name du ALB"
  value       = aws_lb.api.dns_name
}

output "alb_arn" {
  description = "ARN du ALB"
  value       = aws_lb.api.arn
}

output "alb_zone_id" {
  description = "Zone ID du ALB (pour Route53)"
  value       = aws_lb.api.zone_id
}

# Target Group
output "target_group_arn" {
  description = "ARN du target group"
  value       = aws_lb_target_group.api.arn
}

# ECR Repository
output "ecr_repository_url" {
  description = "URL du repository ECR"
  value       = aws_ecr_repository.api.repository_url
}

output "ecr_repository_name" {
  description = "Nom du repository ECR"
  value       = aws_ecr_repository.api.name
}

output "ecr_repository_arn" {
  description = "ARN du repository ECR"
  value       = aws_ecr_repository.api.arn
}

# CloudWatch Log Group
output "log_group_name" {
  description = "Nom du log group CloudWatch"
  value       = aws_cloudwatch_log_group.api.name
}

output "log_group_arn" {
  description = "ARN du log group CloudWatch"
  value       = aws_cloudwatch_log_group.api.arn
}

# Auto Scaling
output "autoscaling_target_id" {
  description = "ID de la cible d'auto-scaling"
  value       = aws_appautoscaling_target.api.id
}


output "alb_arn_suffix" {
  description = "ARN suffix du ALB pour CloudWatch metrics"
  value       = split(":", aws_lb.api.arn)[5]
}

output "target_group_arn_suffix" {
  description = "ARN suffix du target group pour CloudWatch metrics"
  value       = split(":", aws_lb_target_group.api.arn)[5]
}