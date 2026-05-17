output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block du VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID du subnet public"
  value       = aws_subnet.public.id
}

output "private_subnet_ids" {
  description = "IDs des subnets privés"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "nat_gateway_id" {
  description = "ID du NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "internet_gateway_id" {
  description = "ID de l'Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "compute_security_group_id" {
  description = "ID du security group pour EC2"
  value       = aws_security_group.compute.id
}

output "database_security_group_id" {
  description = "ID du security group pour RDS"
  value       = aws_security_group.database.id
}

output "api_security_group_id" {
  description = "ID du security group pour API"
  value       = aws_security_group.api.id
}

output "transit_gateway_attachment_id" {
  description = "ID de l'attachment Transit Gateway"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.id
}
