# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CLOUDWATCH ALARMS - INFRASTRUCTURE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LOCALS - Conditions pour ressources dynamiques
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

locals {
  rds_enabled = var.rds_instance_id != ""
  ecs_enabled = var.ecs_cluster_name != "" && var.ecs_service_name != ""
}
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ALARMES: EC2
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  for_each = var.ec2_instance_ids

  alarm_name          = "${var.project_name}-ec2-${each.key}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 ${each.key} - CPU > 80%"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.warning.arn]
  ok_actions          = [aws_sns_topic.info.arn]

  dimensions = {
    InstanceId = each.value
  }

  tags = {
    CDNU     = each.key
    Severity = "Warning"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
  for_each = var.ec2_instance_ids

  alarm_name          = "${var.project_name}-ec2-${each.key}-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "EC2 ${each.key} - Status check échoué"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.critical.arn]
  ok_actions          = [aws_sns_topic.info.arn]

  dimensions = {
    InstanceId = each.value
  }

  tags = {
    CDNU     = each.key
    Severity = "Critical"
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ALARMES: RDS (avec for_each)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ALARMES: RDS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  count = var.enable_rds_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS - CPU > 80%"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.warning.arn]
  ok_actions          = [aws_sns_topic.info.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = {
    Severity = "Warning"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  count = var.enable_rds_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 2147483648
  alarm_description   = "RDS - Espace disque < 2 GB"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.critical.arn]
  ok_actions          = [aws_sns_topic.info.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = {
    Severity = "Critical"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  count = var.enable_rds_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS - Trop de connexions actives"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.warning.arn]
  ok_actions          = [aws_sns_topic.info.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = {
    Severity = "Warning"
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ALARMES: ECS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  count = var.enable_ecs_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS - CPU > 80%"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.warning.arn]
  ok_actions          = [aws_sns_topic.info.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = {
    Severity = "Warning"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  count = var.enable_ecs_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "ECS - Memory > 85%"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.warning.arn]
  ok_actions          = [aws_sns_topic.info.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = {
    Severity = "Warning"
  }
}
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ALARMES: APPLICATION (custom metrics)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "${var.project_name}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Error500Count"
  namespace           = "CDNU/Application"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Taux d'erreur 500 élevé"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.critical.arn]
  ok_actions          = [aws_sns_topic.info.arn]

  tags = {
    Severity = "Critical"
  }
}

resource "aws_cloudwatch_metric_alarm" "db_connection_errors_alarm" {
  alarm_name          = "${var.project_name}-db-connection-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DatabaseConnectionErrors"
  namespace           = "CDNU/Database"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Erreurs de connexion DB répétées"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.critical.arn]
  ok_actions          = [aws_sns_topic.info.arn]

  tags = {
    Severity = "Critical"
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ALARMES: BUDGET (coûts)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_budgets_budget" "monthly_cost" {
  count = var.enable_cost_alerts ? 1 : 0

  name              = "${var.project_name}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.monthly_budget_limit
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2026-01-01_00:00"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}