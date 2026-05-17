# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NAT GATEWAY (G4)
# NAT Gateway pour permettre Internet depuis subnets privés
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Elastic IP pour NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.cdnu_name}-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway dans subnet public
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${var.cdnu_name}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.main]
}
