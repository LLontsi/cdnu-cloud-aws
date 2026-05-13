output "id" {
  description = "ID du Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "arn" {
  description = "ARN du Transit Gateway"
  value       = aws_ec2_transit_gateway.main.arn
}

output "route_table_id" {
  description = "ID de la route table Transit Gateway"
  value       = aws_ec2_transit_gateway_route_table.main.id
}

output "amazon_side_asn" {
  description = "ASN Amazon du Transit Gateway"
  value       = aws_ec2_transit_gateway.main.amazon_side_asn
}
