# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VARIABLES - MODULE MONITORING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ALERTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "alert_email" {
  description = "Email pour recevoir les alertes"
  type        = string
  default     = ""
}

variable "alert_phone" {
  description = "Numéro de téléphone pour SMS (format: +33612345678)"
  type        = string
  default     = ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RESSOURCES À MONITORER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "ec2_instance_ids" {
  description = "Map des instance IDs EC2 à monitorer (key: nom CDNU, value: instance ID)"
  type        = map(string)
  default     = {}
}

variable "rds_instance_id" {
  description = "ID de l'instance RDS à monitorer"
  type        = string
  default     = ""
}

variable "ecs_cluster_name" {
  description = "Nom du cluster ECS à monitorer"
  type        = string
  default     = ""
}

variable "ecs_service_name" {
  description = "Nom du service ECS à monitorer"
  type        = string
  default     = ""
}

variable "alb_arn_suffix" {
  description = "ARN suffix du ALB"
  type        = string
  default     = ""
}

variable "target_group_arn_suffix" {
  description = "ARN suffix du target group"
  type        = string
  default     = ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "enable_composite_alarms" {
  description = "Activer les alarmes composites"
  type        = bool
  default     = true
}

variable "enable_cost_alerts" {
  description = "Activer les alertes de coûts"
  type        = bool
  default     = true
}

variable "monthly_budget_limit" {
  description = "Budget mensuel en USD"
  type        = string
  default     = "500"
}

variable "dashboard_name" {
  description = "Nom du dashboard CloudWatch"
  type        = string
  default     = ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TAGS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "tags" {
  description = "Tags additionnels"
  type        = map(string)
  default     = {}
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FLAGS POUR ALARMES CONDITIONNELLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "enable_rds_alarms" {
  description = "Activer les alarmes RDS"
  type        = bool
  default     = false
}

variable "enable_ecs_alarms" {
  description = "Activer les alarmes ECS"
  type        = bool
  default     = false
}

variable "enable_alb_alarms" {
  description = "Activer les alarmes ALB"
  type        = bool
  default     = false
}
