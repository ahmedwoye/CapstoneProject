# -------------------------------
#  VPC
# -------------------------------
resource "aws_vpc" "project_network" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Project_network"
  }
}

# -------------------------------
#  Internet Gateway (Public Subnets)
# -------------------------------
resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_network.id

  tags = {
    Name = "project_igw"
  }
}

# -------------------------------
#  Public Subnets
# -------------------------------
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.project_network.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "public_project_subnet_1"
    Tier = "Web App Tier"
  }
}

# -------------------------------
#  Private Subnets
# -------------------------------
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.project_network.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "private_project_subnet_1"
    Tier = "Application Tier"
  }
}


# -------------------------------
#  Public Route Table (for IGW)
# -------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------------
#  NAT Gateway for Private Subnets
# -------------------------------

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = { Name = "nat-gw" }
}

# -------------------------------
#  Private Route Table (for Private Subnets via NAT)
# -------------------------------
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.project_network.id

  tags = {
    Name = "private_rt"
  }
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}


# -------------------------------
# S3 Gateway Endpoint (Optional, for private instance access to S3)
# -------------------------------
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.project_network.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public_rt.id, aws_route_table.private_rt.id]

  tags = {
    Name = "s3-endpoint-for-updates"
  }
}