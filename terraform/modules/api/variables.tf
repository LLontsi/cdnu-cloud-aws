# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VARIABLES - MODULE API
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NETWORKING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs des subnets publics pour ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs des subnets privés pour ECS tasks"
  type        = list(string)
}

variable "api_security_group_id" {
  description = "ID du security group pour ECS tasks"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID du security group pour ALB"
  type        = string
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ECS CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "task_cpu" {
  description = "CPU pour la task ECS (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "512"
}

variable "task_memory" {
  description = "Mémoire pour la task ECS (MB)"
  type        = string
  default     = "1024"
}

variable "desired_count" {
  description = "Nombre de tasks désirées"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Capacité minimum pour auto-scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Capacité maximum pour auto-scaling"
  type        = number
  default     = 10
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# IAM ROLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "ecs_task_execution_role_arn" {
  description = "ARN du rôle ECS Task Execution"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN du rôle ECS Task"
  type        = string
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DATABASE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "database_endpoint" {
  description = "Endpoint de la base de données RDS"
  type        = string
}

variable "database_credentials_secret_arn" {
  description = "ARN du secret Secrets Manager contenant les credentials DB"
  type        = string
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ALB
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "certificate_arn" {
  description = "ARN du certificat ACM pour HTTPS"
  type        = string
  default     = ""
}

variable "alb_logs_bucket_id" {
  description = "ID du bucket S3 pour logs ALB"
  type        = string
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TAGS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "tags" {
  description = "Tags additionnels"
  type        = map(string)
  default     = {}
}
