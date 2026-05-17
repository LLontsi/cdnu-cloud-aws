# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Outputs
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

output "transit_gateway_ids" {
  description = "IDs des Transit Gateways"
  value = {
    eu_central_1 = module.transit_gateway_eu_central_1.id
    eu_west_3    = module.transit_gateway_eu_west_3.id
    eu_west_1    = module.transit_gateway_eu_west_1.id
  }
}

output "vpc_ids" {
  description = "IDs des VPCs"
  value = merge(
    { for k, v in module.vpc_eu_central_1 : k => v.vpc_id },
    { for k, v in module.vpc_eu_west_3 : k => v.vpc_id },
    { for k, v in module.vpc_eu_west_1 : k => v.vpc_id }
  )
}

output "ec2_public_ips" {
  description = "IPs publiques EC2"
  value = merge(
    { for k, v in module.compute_eu_central_1 : k => v.public_ip },
    { for k, v in module.compute_eu_west_3 : k => v.public_ip },
    { for k, v in module.compute_eu_west_1 : k => v.public_ip }
  )
}

output "rds_endpoint" {
  description = "Endpoint RDS"
  value       = module.database.endpoint
  sensitive   = true
}