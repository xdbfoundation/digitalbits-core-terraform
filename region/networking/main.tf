# --- region/networking/main.tf ---

resource "random_string" "vpc_suffix" {
  length      = 6
  min_numeric = 1
  special     = false
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "aws_vpc" "livenet_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Livenet VPC-${random_string.vpc_suffix.result}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "livenet_public_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.livenet_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]
  tags = {
    Name = "Livenet Public ${count.index + 1}"
  }
}
resource "aws_route_table_association" "livenet_public_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.livenet_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.livenet_public_rt.id
}

resource "aws_subnet" "livenet_private_subnet" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.livenet_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = false
  tags = {
    "Name" = "Livenet Private ${count.index + 1}"
  }
}


resource "aws_internet_gateway" "livenet_internet_gateway" {
  vpc_id = aws_vpc.livenet_vpc.id
  tags = {
    Name = "Livenet IGW"
  }
}

resource "aws_route_table" "livenet_public_rt" {
  vpc_id = aws_vpc.livenet_vpc.id
  tags = {
    Name = "Livenet Public"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.livenet_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.livenet_internet_gateway.id
}

resource "aws_default_route_table" "livenet_private_rt" {
  default_route_table_id = aws_vpc.livenet_vpc.default_route_table_id
  tags = {
    Name = "Livenet Private"
  }
}

resource "aws_security_group" "livenet_sg" {
  tags = {
    Name = "Public PEER/HTTP SG"
  }
  name        = "public_sg"
  description = "Security Group for Public Access"
  vpc_id      = aws_vpc.livenet_vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 11625
    to_port     = 11625
    protocol    = "tcp"

  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_security_group" "rds_sg" {
  tags = {
    Name = "RDS SG"
  }
  name        = "rds_sg"
  description = "Security Group for RDS Access"
  vpc_id      = aws_vpc.livenet_vpc.id
  ingress {
    security_groups = [aws_security_group.livenet_sg.id]
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_db_subnet_group" "livenet_rds_subnetgroup" {
  name       = "livenet_rds_sng"
  subnet_ids = aws_subnet.livenet_private_subnet.*.id
  tags = {
    Name = "Livenet RDS subnet group"
  }
}