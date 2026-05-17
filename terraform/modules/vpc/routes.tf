# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ROUTE TABLES (G4)
# Tables de routage pour subnets public et privés
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ROUTE TABLE PUBLIC
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.cdnu_name}-public-rt"
    Type = "Public"
  }
}

# Route Internet via IGW
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Route vers autres VPC via Transit Gateway
resource "aws_route" "public_to_tgw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.transit_gateway_id
}

# Association subnet public
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ROUTE TABLE PRIVATE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.cdnu_name}-private-rt"
    Type = "Private"
  }
}

# Route Internet via NAT Gateway
resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Route vers autres VPC via Transit Gateway
resource "aws_route" "private_to_tgw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.transit_gateway_id
}

# Associations subnets privés
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}
