# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OUTPUTS - MODULE MONITORING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# SNS Topics
output "critical_topic_arn" {
  description = "ARN du topic SNS pour alertes critiques"
  value       = aws_sns_topic.critical.arn
}

output "warning_topic_arn" {
  description = "ARN du topic SNS pour alertes warning"
  value       = aws_sns_topic.warning.arn
}

output "info_topic_arn" {
  description = "ARN du topic SNS pour alertes info"
  value       = aws_sns_topic.info.arn
}

# Log Groups
output "application_log_group_name" {
  description = "Nom du log group application"
  value       = aws_cloudwatch_log_group.application.name
}

output "infrastructure_log_group_name" {
  description = "Nom du log group infrastructure"
  value       = aws_cloudwatch_log_group.infrastructure.name
}

# Dashboard
output "dashboard_url" {
  description = "URL du dashboard CloudWatch"
  value       = var.dashboard_name != "" ? "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main[0].dashboard_name}" : ""
}

output "dashboard_name" {
  description = "Nom du dashboard CloudWatch"
  value       = var.dashboard_name != "" ? aws_cloudwatch_dashboard.main[0].dashboard_name : ""
}


