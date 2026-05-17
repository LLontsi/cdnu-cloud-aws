# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: MONITORING (G6)
# CloudWatch Dashboards + SNS Notifications
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SNS TOPICS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


# Topic: Alertes critiques
resource "aws_sns_topic" "critical" {
  name = "${var.project_name}-critical-alerts"

  display_name = "CDNU Critical Alerts"

  tags = {
    Name     = "${var.project_name}-critical-alerts"
    Severity = "Critical"
  }
}

# Topic: Alertes warning
resource "aws_sns_topic" "warning" {
  name = "${var.project_name}-warning-alerts"

  display_name = "CDNU Warning Alerts"

  tags = {
    Name     = "${var.project_name}-warning-alerts"
    Severity = "Warning"
  }
}

# Topic: Alertes info
resource "aws_sns_topic" "info" {
  name = "${var.project_name}-info-alerts"

  display_name = "CDNU Info Alerts"

  tags = {
    Name     = "${var.project_name}-info-alerts"
    Severity = "Info"
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SNS SUBSCRIPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Email pour alertes critiques
resource "aws_sns_topic_subscription" "critical_email" {
  count = var.alert_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.critical.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Email pour alertes warning
resource "aws_sns_topic_subscription" "warning_email" {
  count = var.alert_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.warning.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# SMS pour alertes critiques (optionnel)
resource "aws_sns_topic_subscription" "critical_sms" {
  count = var.alert_phone != "" ? 1 : 0

  topic_arn = aws_sns_topic.critical.arn
  protocol  = "sms"
  endpoint  = var.alert_phone
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SNS TOPIC POLICY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    sid    = "AllowCloudWatchToPublish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    actions = [
      "SNS:Publish"
    ]

    resources = [
      aws_sns_topic.critical.arn,
      aws_sns_topic.warning.arn,
      aws_sns_topic.info.arn
    ]
  }
}

resource "aws_sns_topic_policy" "critical" {
  arn = aws_sns_topic.critical.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudWatchAlarms"
      Effect = "Allow"
      Principal = {
        Service = "cloudwatch.amazonaws.com"
      }
      Action   = "SNS:Publish"
      Resource = aws_sns_topic.critical.arn  # ← UNE SEULE ressource
    }]
  })
}

resource "aws_sns_topic_policy" "warning" {
  arn = aws_sns_topic.warning.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudWatchAlarms"
      Effect = "Allow"
      Principal = {
        Service = "cloudwatch.amazonaws.com"
      }
      Action   = "SNS:Publish"
      Resource = aws_sns_topic.warning.arn  # ← UNE SEULE ressource
    }]
  })
}

resource "aws_sns_topic_policy" "info" {
  arn = aws_sns_topic.info.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudWatchAlarms"
      Effect = "Allow"
      Principal = {
        Service = "cloudwatch.amazonaws.com"
      }
      Action   = "SNS:Publish"
      Resource = aws_sns_topic.info.arn  # ← UNE SEULE ressource
    }]
  })
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CLOUDWATCH LOG GROUPS (centralisé)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_cloudwatch_log_group" "application" {
  name              = "/cdnu/${var.project_name}/application"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-app-logs"
  }
}

resource "aws_cloudwatch_log_group" "infrastructure" {
  name              = "/cdnu/${var.project_name}/infrastructure"
  retention_in_days = 90

  tags = {
    Name = "${var.project_name}-infra-logs"
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CLOUDWATCH METRIC FILTERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Filtre: Erreurs 500
#resource "aws_cloudwatch_log_metric_filter" "error_500" {
#  name           = "${var.project_name}-error-500"
#  log_group_name = "/ecs/${var.project_name}-api"
#  
#  pattern = "5*"  # ← Pattern ultra-simple
#  
#  metric_transformation {
#    name      = "Error500Count"
#    namespace = "CDNU/Application"
#    value     = "1"
#  }
#}
#
#resource "aws_cloudwatch_log_metric_filter" "error_400" {
#  name           = "${var.project_name}-error-400"
#  log_group_name = "/ecs/${var.project_name}-api"
#  
#  pattern = "4*"  # ← Pattern ultra-simple
#  
#  metric_transformation {
#    name      = "Error400Count"
#    namespace = "CDNU/Application"
#    value     = "1"
#  }
#}
#
#resource "aws_cloudwatch_log_metric_filter" "db_connection_errors" {
#  name           = "${var.project_name}-db-errors"
#  log_group_name = "/ecs/${var.project_name}-api"
#  
#  pattern = "\"connection error\""  # ← Pattern simple
#  
#  metric_transformation {
#    name      = "DatabaseConnectionErrors"
#    namespace = "CDNU/Database"
#    value     = "1"
#  }
#}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CLOUDWATCH COMPOSITE ALARMS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Composite Alarm: Service complètement down
#resource "aws_cloudwatch_composite_alarm" "service_down" {
#  count = var.enable_composite_alarms ? 1 : 0
#
#  alarm_name        = "${var.project_name}-service-completely-down"
#  alarm_description = "Service complètement indisponible (multiple checks)"
#  actions_enabled   = true
#  alarm_actions     = [aws_sns_topic.critical.arn]
#  ok_actions        = [aws_sns_topic.info.arn]
#
#  alarm_rule = "ALARM(${var.project_name}-unhealthy-targets) AND ALARM(${var.project_name}-high-error-rate)"
#
#  tags = {
#    Severity = "Critical"
#  }
#}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CLOUDWATCH INSIGHTS QUERIES (pré-définies)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_cloudwatch_query_definition" "error_analysis" {
  name = "${var.project_name}/error-analysis"

  log_group_names = [
    aws_cloudwatch_log_group.application.name
  ]

  query_string = <<-QUERY
    fields @timestamp, @message
    | filter @message like /ERROR/
    | stats count() by bin(5m)
  QUERY
}

resource "aws_cloudwatch_query_definition" "slow_requests" {
  name = "${var.project_name}/slow-requests"

  log_group_names = [
    aws_cloudwatch_log_group.application.name
  ]

  query_string = <<-QUERY
    fields @timestamp, @message, duration
    | filter duration > 1000
    | sort duration desc
    | limit 100
  QUERY
}

resource "aws_cloudwatch_query_definition" "top_endpoints" {
  name = "${var.project_name}/top-endpoints"

  log_group_names = [
    aws_cloudwatch_log_group.application.name
  ]

  query_string = <<-QUERY
    fields @timestamp, endpoint, method
    | stats count() as request_count by endpoint, method
    | sort request_count desc
    | limit 20
  QUERY
}
