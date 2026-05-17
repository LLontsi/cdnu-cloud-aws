variable "cdnu_name" {
  description = "Nom du CDNU"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block du VPC"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone pour le VPC"
  type        = string
}

variable "transit_gateway_id" {
  description = "ID du Transit Gateway"
  type        = string
}
