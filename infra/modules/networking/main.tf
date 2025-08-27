resource "aws_vpc" "serverless_custom_vpc" {
  cidr_block =  var.cidr_block
  enable_dns_support   = true     # ✅ REQUIRED
  enable_dns_hostnames = true     # ✅ REQUIRED
  tags = {
    Name = "custom-vpc"
  }
}


resource "aws_subnet" "serverless_public_subnet" {
  vpc_id     = aws_vpc.serverless_custom_vpc.id
  cidr_block = var.public_subnet
  availability_zone = "us-east-1a"
  tags = {
    Name = "serverless_public_subnet"
  }
}


resource "aws_subnet" "serverless_private_subnet" {
  vpc_id     = aws_vpc.serverless_custom_vpc.id
  cidr_block = var.private_subnet
  availability_zone = "us-east-1a"
  tags = {
    Name = "serverless_private_subnet"
  }
}


resource "aws_internet_gateway" "serverless_custom_igw" {
  vpc_id = aws_vpc.serverless_custom_vpc.id
  tags = {
    Name = "serverless_custom_igw"
  }
}


resource "aws_route_table" "serverless_route_table" {
  vpc_id = "${aws_vpc.serverless_custom_vpc.id}"
  #send all traffic from inside to outsite(public) via igw
  #This sends all outbound traffic (to the internet) to the Internet Gateway (IGW)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.serverless_custom_igw.id
  }
  # cycle error as thisn eed vpc endpoint prefix and endpoints needs route table id so use
  # Resource: aws_route
  # Provides a resource to create a routing table entry (a route) in a VPC routing table.
  
  # route {
  #   destination_prefix_list_id = aws_vpc_endpoint.vpc_endpoint_for_s3.prefix_list_id
  #   gateway_id     = aws_vpc_endpoint.vpc_endpoint_for_s3.id
  # }

  tags = {
    Name = "serverless_route_table"
  }
}
# according to gpt, it automatically created
# resource "aws_route" "s3_gateway_route" {
#     route_table_id         = aws_route_table.serverless_route_table.id
#     destination_prefix_list_id = aws_vpc_endpoint.vpc_endpoint_for_s3.prefix_list_id
#     gateway_id             = aws_vpc_endpoint.vpc_endpoint_for_s3.id
# }

resource "aws_route_table" "serverless_private_route_table" {
  vpc_id = aws_vpc.serverless_custom_vpc.id

  tags = {
    Name = "serverless_private_route_table"
  }
}


resource "aws_route_table_association" "serverless_route_table_association" {
  subnet_id      = "${aws_subnet.serverless_public_subnet.id}"
  route_table_id = "${aws_route_table.serverless_route_table.id}"
}

resource "aws_route_table_association" "serverless_private_route_table_association" {
  subnet_id      = aws_subnet.serverless_private_subnet.id
  route_table_id = aws_route_table.serverless_private_route_table.id
}



data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

data "aws_vpc_endpoint_service" "dynamodb" {
  service      = "dynamodb"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "vpc_endpoint_for_s3" {
  vpc_id            = aws_vpc.serverless_custom_vpc.id
  # Vpc Endpoint Service 'com.amazonaws.us-west-2.s3' does not exist
  # Hardcoded it but getting error so do dynamic way....
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.serverless_private_route_table.id]

  tags = {
    Name = "s3-gateway-endpoint"
  }
}

resource "aws_vpc_endpoint" "vpc_endpoint_for_dynamodb" {
  vpc_id            = aws_vpc.serverless_custom_vpc.id
  service_name      = data.aws_vpc_endpoint_service.dynamodb.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.serverless_private_route_table.id]

  tags = {
    Name = "dynamodb-gateway-endpoint"
  }
}


resource "aws_vpc_endpoint" "sns_endpoint" {
  vpc_id            = aws_vpc.serverless_custom_vpc.id
  service_name      = "com.amazonaws.us-east-1.sns"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.serverless_private_subnet.id]
  security_group_ids = [var.serverless_sns_security_group_id]

  private_dns_enabled = true
}

