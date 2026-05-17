# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VARIABLES - MODULE IAM
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "cicd_trust_principal_arn" {
  description = "ARN du principal autorisé à assumer le rôle CI/CD"
  type        = string
  default     = "*"
}

variable "developer_trust_principal_arn" {
  description = "ARN du principal autorisé à assumer le rôle développeur"
  type        = string
  default     = "*"
}

variable "admin_trust_principal_arn" {
  description = "ARN du principal autorisé à assumer le rôle admin"
  type        = string
  default     = "*"
}

variable "tags" {
  description = "Tags additionnels"
  type        = map(string)
  default     = {}
}
