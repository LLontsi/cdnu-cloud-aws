# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: Transit Gateway (G3)
# Hub central pour interconnexion des 11 VPC CDNU
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_ec2_transit_gateway" "main" {
  description = "Transit Gateway Hub pour 11 CDNU"
  
  # Configuration réseau
  amazon_side_asn                 = 64512
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  
  # Features
  dns_support                     = "enable"
  vpn_ecmp_support               = "disable"
  auto_accept_shared_attachments = "enable"
  
  tags = {
    Name        = "${var.project_name}-transit-gateway"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Group       = "G3"
  }
}

# Route Table Transit Gateway
resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  
  tags = {
    Name        = "${var.project_name}-tgw-rt"
    Environment = var.environment
  }
}

# Route par défaut (si besoin de routage Internet via NAT centralisé)
# Optionnel: peut être activé plus tard si nécessaire
# resource "aws_ec2_transit_gateway_route" "default" {
#   destination_cidr_block         = "0.0.0.0/0"
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
# }
