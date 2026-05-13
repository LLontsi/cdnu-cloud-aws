# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CDNU CLOUD AWS - Configuration Terraform Principale
# Groupes: G3 (Transit Gateway) + G4 (VPC/Compute) + G5 (RDS/S3/IAM) + G6 (API)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = var.tags
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DATA SOURCES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: TRANSIT GATEWAY (G3)
# Hub central pour interconnexion 11 VPC
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "transit_gateway" {
  source = "./modules/transit-gateway"
  
  project_name = var.project_name
  environment  = var.environment
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: VPC (G4) - 11 VPCs
# VPC par CDNU avec subnets, NAT, routes, security
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "vpc" {
  source   = "./modules/vpc"
  for_each = { for k, v in var.cdnu_configs : k => v if v.deploy }
  
  cdnu_name          = each.key
  vpc_cidr           = each.value.vpc_cidr
  availability_zone  = each.value.az
  transit_gateway_id = module.transit_gateway.id
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: COMPUTE (G4) - 11 EC2 instances
# Instance EC2 par CDNU avec user-data bootstrap
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "compute" {
  source   = "./modules/compute"
  for_each = { for k, v in var.cdnu_configs : k => v if v.deploy }
  
  cdnu_name             = each.key
  instance_type         = each.value.instance_type
  ami_id                = data.aws_ami.amazon_linux_2.id
  subnet_id             = module.vpc[each.key].public_subnet_id
  security_group_id     = module.vpc[each.key].compute_security_group_id
  iam_instance_profile  = module.iam.ec2_instance_profile_name
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: DATABASE (G5)
# RDS PostgreSQL Multi-AZ partagé
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "database" {
  source = "./modules/database"
  
  project_name      = var.project_name
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  engine_version    = var.db_engine_version
  master_username   = var.db_master_username
  master_password   = var.db_password
  
  # Utiliser subnets privés de tous les VPC
  subnet_ids = flatten([
    for vpc in module.vpc : vpc.private_subnet_ids
  ])
  
  # Security groups permettant accès depuis tous les VPC
  vpc_security_group_ids = [
    for vpc in module.vpc : vpc.database_security_group_id
  ]
  
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  multi_az                = true
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: STORAGE (G5) - 11 Buckets S3
# Bucket S3 par CDNU avec lifecycle et versioning
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "storage" {
  source   = "./modules/storage"
  for_each = { for k, v in var.cdnu_configs : k => v if v.deploy }
  
  cdnu_name    = each.key
  project_name = var.project_name
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: IAM (G5)
# Rôles IAM pour EC2, Lambda, CI/CD
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "iam" {
  source = "./modules/iam"
  
  project_name = var.project_name
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: API (G6) - Infrastructure API
# ECS/Lambda pour API "État des Services"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "api" {
  source = "./modules/api"
  
  project_name           = var.project_name
  vpc_id                 = module.vpc["yaounde"].vpc_id
  public_subnet_ids      = [module.vpc["yaounde"].public_subnet_id]
  api_security_group_id  = module.vpc["yaounde"].api_security_group_id
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: MONITORING (G6) - CloudWatch
# Monitoring et alertes CloudWatch
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "monitoring" {
  source = "./modules/monitoring"
  
  project_name = var.project_name
  alarm_email  = var.alarm_email
  
  # Ressources à monitorer
  instance_ids = [
    for compute in module.compute : compute.instance_id
  ]
  
  rds_instance_id = module.database.instance_id
}
