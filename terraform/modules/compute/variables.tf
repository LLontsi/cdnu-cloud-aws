variable "cdnu_name" {
  description = "Nom du CDNU"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
}

variable "ami_id" {
  description = "ID de l'AMI Amazon Linux 2"
  type        = string
}

variable "subnet_id" {
  description = "ID du subnet où déployer l'instance"
  type        = string
}

variable "security_group_id" {
  description = "ID du security group"
  type        = string
}

variable "iam_instance_profile" {
  description = "Nom du profil IAM pour l'instance"
  type        = string
}
