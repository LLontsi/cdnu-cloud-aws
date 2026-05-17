# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROVIDERS - 3 RÉGIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

provider "aws" {
  alias  = "eu_central_1"
  region = "eu-central-1"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "eu_west_3"
  region = "eu-west-3"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"

  default_tags {
    tags = var.tags
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DATA SOURCES - Par région
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

data "aws_ami" "amazon_linux_2_eu_central_1" {
  provider    = aws.eu_central_1
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "amazon_linux_2_eu_west_3" {
  provider    = aws.eu_west_3
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "amazon_linux_2_eu_west_1" {
  provider    = aws.eu_west_1
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TRANSIT GATEWAY - Par région
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "transit_gateway_eu_central_1" {
  source = "./modules/transit-gateway"
  providers = {
    aws = aws.eu_central_1
  }

  project_name = "${var.project_name}-eu-central-1"
  environment  = var.environment
}

module "transit_gateway_eu_west_3" {
  source = "./modules/transit-gateway"
  providers = {
    aws = aws.eu_west_3
  }

  project_name = "${var.project_name}-eu-west-3"
  environment  = var.environment
}

module "transit_gateway_eu_west_1" {
  source = "./modules/transit-gateway"
  providers = {
    aws = aws.eu_west_1
  }

  project_name = "${var.project_name}-eu-west-1"
  environment  = var.environment
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VPC - eu-central-1
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "vpc_eu_central_1" {
  source = "./modules/vpc"
  for_each = {
    for k, v in var.cdnu_configs : k => v
    if v.deploy && v.region == "eu-central-1"
  }

  providers = {
    aws = aws.eu_central_1
  }

  cdnu_name          = each.key
  vpc_cidr           = each.value.vpc_cidr
  availability_zone  = each.value.az
  transit_gateway_id = module.transit_gateway_eu_central_1.id
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VPC - eu-west-3
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "vpc_eu_west_3" {
  source = "./modules/vpc"
  for_each = {
    for k, v in var.cdnu_configs : k => v
    if v.deploy && v.region == "eu-west-3"
  }

  providers = {
    aws = aws.eu_west_3
  }

  cdnu_name          = each.key
  vpc_cidr           = each.value.vpc_cidr
  availability_zone  = each.value.az
  transit_gateway_id = module.transit_gateway_eu_west_3.id
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VPC - eu-west-1
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "vpc_eu_west_1" {
  source = "./modules/vpc"
  for_each = {
    for k, v in var.cdnu_configs : k => v
    if v.deploy && v.region == "eu-west-1"
  }

  providers = {
    aws = aws.eu_west_1
  }

  cdnu_name          = each.key
  vpc_cidr           = each.value.vpc_cidr
  availability_zone  = each.value.az
  transit_gateway_id = module.transit_gateway_eu_west_1.id
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: IAM (G5)
# Rôles IAM centralisés (région par défaut)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "iam" {
  source = "./modules/iam"

  providers = {
    aws = aws.eu_central_1
  }

  project_name = var.project_name
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPUTE - eu-central-1
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "compute_eu_central_1" {
  source = "./modules/compute"
  for_each = {
    for k, v in var.cdnu_configs : k => v
    if v.deploy && v.region == "eu-central-1"
  }

  providers = {
    aws = aws.eu_central_1
  }

  cdnu_name            = each.key
  instance_type        = each.value.instance_type
  ami_id               = data.aws_ami.amazon_linux_2_eu_central_1.id
  subnet_id            = module.vpc_eu_central_1[each.key].public_subnet_id
  security_group_id    = module.vpc_eu_central_1[each.key].compute_security_group_id
  iam_instance_profile = module.iam.ec2_instance_profile_name
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPUTE - eu-west-3
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "compute_eu_west_3" {
  source = "./modules/compute"
  for_each = {
    for k, v in var.cdnu_configs : k => v
    if v.deploy && v.region == "eu-west-3"
  }

  providers = {
    aws = aws.eu_west_3
  }

  cdnu_name            = each.key
  instance_type        = each.value.instance_type
  ami_id               = data.aws_ami.amazon_linux_2_eu_west_3.id
  subnet_id            = module.vpc_eu_west_3[each.key].public_subnet_id
  security_group_id    = module.vpc_eu_west_3[each.key].compute_security_group_id
  iam_instance_profile = module.iam.ec2_instance_profile_name
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPUTE - eu-west-1
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "compute_eu_west_1" {
  source = "./modules/compute"
  for_each = {
    for k, v in var.cdnu_configs : k => v
    if v.deploy && v.region == "eu-west-1"
  }

  providers = {
    aws = aws.eu_west_1
  }

  cdnu_name            = each.key
  instance_type        = each.value.instance_type
  ami_id               = data.aws_ami.amazon_linux_2_eu_west_1.id
  subnet_id            = module.vpc_eu_west_1[each.key].public_subnet_id
  security_group_id    = module.vpc_eu_west_1[each.key].compute_security_group_id
  iam_instance_profile = module.iam.ec2_instance_profile_name
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DATABASE - eu-central-1 uniquement
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "database" {
  source = "./modules/database"
  providers = {
    aws = aws.eu_central_1
  }

  project_name      = var.project_name
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  engine_version    = var.db_engine_version
  master_username   = var.db_master_username
  master_password   = var.db_password

  subnet_ids = module.vpc_eu_central_1["yaounde"].private_subnet_ids

  vpc_security_group_ids = [
    module.vpc_eu_central_1["yaounde"].database_security_group_id
  ]

  backup_retention_period = 1
  backup_window           = "03:00-04:00"
  multi_az                = false
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: STORAGE (G5) - 11 Buckets S3
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "storage" {
  source   = "./modules/storage"
  for_each = { for k, v in var.cdnu_configs : k => v if v.deploy }

  providers = {
    aws = aws.eu_central_1
  }

  cdnu_name    = each.key
  project_name = var.project_name
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUCKET S3 POUR LOGS ALB
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_s3_bucket" "alb_logs" {
  provider = aws.eu_central_1
  bucket   = "${var.project_name}-alb-logs-${var.aws_account_id}"
  force_destroy = true
}
resource "aws_s3_bucket_policy" "alb_logs" {
  provider = aws.eu_central_1
  bucket   = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::054676820928:root"  # ELB service account pour eu-central-1
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.alb_logs.arn
      }
    ]
  })
}
resource "aws_s3_bucket_versioning" "alb_logs" {
  provider = aws.eu_central_1
  bucket   = aws_s3_bucket.alb_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  provider = aws.eu_central_1
  bucket   = aws_s3_bucket.alb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  provider = aws.eu_central_1
  bucket   = aws_s3_bucket.alb_logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {} # ← AJOUTER CETTE LIGNE

    expiration {
      days = 90
    }
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECRETS MANAGER POUR DATABASE CREDENTIALS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_secretsmanager_secret" "db_credentials" {
  provider = aws.eu_central_1
  name     = "${var.project_name}/rds/credentials"
  recovery_window_in_days = 0
  description = "RDS database credentials for CDNU Cloud"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  provider  = aws.eu_central_1
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_master_username
    password = var.db_password
    engine   = "postgres"
    host     = module.database.endpoint
    port     = 5432
    dbname   = var.db_database_name
  })
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: API (G6) - Infrastructure API
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "api" {
  source = "./modules/api"

  providers = {
    aws = aws.eu_central_1
  }

  project_name       = var.project_name
  vpc_id             = module.vpc_eu_central_1["yaounde"].vpc_id
   public_subnet_ids  = [module.vpc_eu_central_1["yaounde"].public_subnet_id]  # Pour ALB
  private_subnet_ids = module.vpc_eu_central_1["yaounde"].private_subnet_ids 

  api_security_group_id = module.vpc_eu_central_1["yaounde"].compute_security_group_id
  alb_security_group_id = module.vpc_eu_central_1["yaounde"].compute_security_group_id

  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn

  database_endpoint               = module.database.endpoint
  database_credentials_secret_arn = aws_secretsmanager_secret.db_credentials.arn

  alb_logs_bucket_id = aws_s3_bucket.alb_logs.id
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: MONITORING (G6) - CloudWatch
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "monitoring" {
  source = "./modules/monitoring"

  providers = {
    aws = aws.eu_central_1
  }

  project_name = var.project_name

  alert_email = var.alarm_email
  alert_phone = var.alarm_phone

  ec2_instance_ids = {
    for k, v in module.compute_eu_central_1 : k => v.instance_id
  }

  rds_instance_id = module.database.instance_id

  ecs_cluster_name = module.api.ecs_cluster_name
  ecs_service_name = module.api.ecs_service_name

  alb_arn_suffix          = module.api.alb_arn_suffix
  target_group_arn_suffix = module.api.target_group_arn_suffix

  dashboard_name = "${var.project_name}-health"

  enable_cost_alerts   = true
  monthly_budget_limit = "500"
}