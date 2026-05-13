# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Variables Globales - CDNU Cloud AWS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "aws_region" {
  description = "Région AWS pour déploiement"
  type        = string
  default     = "eu-central-1"
}

variable "aws_account_id" {
  description = "ID du compte AWS"
  type        = string
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "cdnu-cloud"
}

variable "environment" {
  description = "Environnement (dev/staging/production)"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "Tags globaux appliqués à toutes les ressources"
  type        = map(string)
  default = {
    Project     = "CDNU-Cloud"
    ManagedBy   = "Terraform"
    Institution = "Universite-Yaounde-I"
    Team        = "G3-G4-G5-G6"
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Configuration 11 CDNU
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "cdnu_configs" {
  description = "Configuration des 11 CDNU camerounais"
  type = map(object({
    vpc_cidr      = string
    instance_type = string
    az            = string
    deploy        = bool
  }))
  
  default = {
    yaounde = {
      vpc_cidr      = "10.0.0.0/16"
      instance_type = "t3.micro"
      az            = "eu-central-1a"
      deploy        = true
    }
    douala = {
      vpc_cidr      = "10.1.0.0/16"
      instance_type = "t3.micro"
      az            = "eu-central-1b"
      deploy        = true
    }
    buea = {
      vpc_cidr      = "10.2.0.0/16"
      instance_type = "t3.micro"
      az            = "eu-central-1c"
      deploy        = true
    }
    ngaoundere = {
      vpc_cidr      = "10.3.0.0/16"
      instance_type = "t3.micro"
      az            = "eu-central-1a"
      deploy        = true
    }
    maroua = {
      vpc_cidr      = "10.4.0.0/16"
      instance_type = "t3.micro"
      az            = "eu-central-1b"
      deploy        = true
    }
    garoua = {
      vpc_cidr      = "10.5.0.0/16"
      instance_type = "t3.micro"
      az            = "eu-central-1c"
      deploy        = true
    }
    bamenda = {
      vpc_cidr      = "10.6.0.0/16"
      instance_type = "t3.micro"
      az            = "eu-central-1a"
      deploy        = true
    }
    bafoussam = {
      vpc_cidr      = "10.7.0.0/16"
      instance_type = "t3.micro"
      az            = "eu-central-1b"
      deploy        = true
    }
    bertoua = {
      vpc_cidr      = "10.8.0.0/16"
      instance_type = "t3.micro"
      az            = "eu-central-1c"
      deploy        = true
    }
    ebolowa = {
      vpc_cidr      = "10.9.0.0/16"
      instance_type = "t3.micro"
      az            = "eu-central-1a"
      deploy        = true
    }
    kribi = {
      vpc_cidr      = "10.10.0.0/16"
      instance_type = "t3.micro"
      az            = "eu-central-1b"
      deploy        = true
    }
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Base de Données (G5)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "db_instance_class" {
  description = "Classe d'instance RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Stockage alloué pour RDS (GB)"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "Version PostgreSQL"
  type        = string
  default     = "15.4"
}

variable "db_master_username" {
  description = "Nom d'utilisateur master pour RDS"
  type        = string
  default     = "cdnu_admin"
}

variable "db_password" {
  description = "Mot de passe master RDS (depuis GitHub Secrets)"
  type        = string
  sensitive   = true
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Monitoring (G6)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

variable "alarm_email" {
  description = "Email pour recevoir les alarmes CloudWatch"
  type        = string
}
