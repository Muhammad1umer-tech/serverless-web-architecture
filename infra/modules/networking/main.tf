############################
# Data Sources
############################

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

############################
# VPC
############################

resource "aws_vpc" "serverless_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

############################
# Public Subnet
############################

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.serverless_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet"
  }
}

############################
# Private Subnet
############################

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.serverless_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet"
  }
}

############################
# Internet Gateway
############################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.serverless_vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

############################
# Public Route Table
############################

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.serverless_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

############################
# Private Route Table
############################

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.serverless_vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
  }
}

############################
# Route Table Associations
############################

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

############################
# Gateway VPC Endpoint - S3
############################

data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id            = aws_vpc.serverless_vpc.id
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_route_table.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-s3-endpoint"
  }
}

############################
# Gateway VPC Endpoint - DynamoDB
############################

data "aws_vpc_endpoint_service" "dynamodb" {
  service      = "dynamodb"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "dynamodb_gateway_endpoint" {
  vpc_id            = aws_vpc.serverless_vpc.id
  service_name      = data.aws_vpc_endpoint_service.dynamodb.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_route_table.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-dynamodb-endpoint"
  }
}

############################
# Interface Endpoint - SNS
############################

resource "aws_vpc_endpoint" "sns_interface_endpoint" {
  vpc_id              = aws_vpc.serverless_vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.sns"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet.id]
  security_group_ids  = [var.sns_endpoint_security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.environment}-sns-endpoint"
  }
}