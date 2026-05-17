# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODULE: VPC (G4)
# VPC par CDNU avec subnets public/privé, IGW
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${var.cdnu_name}"
    CDNU = var.cdnu_name
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SUBNETS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Subnet Public
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cdnu_name}-public-subnet"
    Type = "Public"
  }
}

# Subnet Privé 1
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 10)
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.cdnu_name}-private-subnet-1"
    Type = "Private"
  }
}

# Subnet Privé 2 (pour Multi-AZ RDS)
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 11)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.cdnu_name}-private-subnet-2"
    Type = "Private"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INTERNET GATEWAY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.cdnu_name}-igw"
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TRANSIT GATEWAY ATTACHMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = aws_vpc.main.id
  subnet_ids                                      = [aws_subnet.private_1.id] # ← UN SEUL subnet
  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = {
    Name = "${var.cdnu_name}-tgw-attachment"
  }
}
