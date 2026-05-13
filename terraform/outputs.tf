# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Outputs - CDNU Cloud AWS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

output "transit_gateway_id" {
  description = "ID du Transit Gateway"
  value       = module.transit_gateway.id
}

output "transit_gateway_route_table_id" {
  description = "ID de la route table Transit Gateway"
  value       = module.transit_gateway.route_table_id
}

output "vpc_ids" {
  description = "IDs des 11 VPCs"
  value = {
    for k, vpc in module.vpc : k => vpc.vpc_id
  }
}

output "vpc_cidrs" {
  description = "CIDR blocks des 11 VPCs"
  value = {
    for k, v in var.cdnu_configs : k => v.vpc_cidr
  }
}

output "ec2_instance_ids" {
  description = "IDs des instances EC2"
  value = {
    for k, compute in module.compute : k => compute.instance_id
  }
}

output "ec2_public_ips" {
  description = "Adresses IP publiques des instances EC2"
  value = {
    for k, compute in module.compute : k => compute.public_ip
  }
}

output "rds_endpoint" {
  description = "Endpoint de connexion RDS PostgreSQL"
  value       = module.database.endpoint
  sensitive   = true
}

output "rds_instance_id" {
  description = "ID de l'instance RDS"
  value       = module.database.instance_id
}

output "s3_bucket_names" {
  description = "Noms des buckets S3"
  value = {
    for k, storage in module.storage : k => storage.bucket_name
  }
}

output "s3_bucket_arns" {
  description = "ARNs des buckets S3"
  value = {
    for k, storage in module.storage : k => storage.bucket_arn
  }
}

output "iam_ec2_instance_profile_name" {
  description = "Nom du profil d'instance IAM pour EC2"
  value       = module.iam.ec2_instance_profile_name
}

output "iam_ec2_role_arn" {
  description = "ARN du rôle IAM EC2"
  value       = module.iam.ec2_role_arn
}

output "api_endpoint" {
  description = "Endpoint de l'API"
  value       = module.api.api_endpoint
}

output "api_load_balancer_dns" {
  description = "DNS du Load Balancer API"
  value       = module.api.load_balancer_dns
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Informations de compte
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

output "account_id" {
  description = "ID du compte AWS"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "Région AWS utilisée"
  value       = data.aws_region.current.name
}
