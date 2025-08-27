resource "aws_security_group" "serverless_lambda_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.custom_vpc_id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_egress_rule" "example" {
  security_group_id = aws_security_group.serverless_lambda_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


resource "aws_security_group" "serverless_sns_endpoint_sg" {
  name        = "allow_tls_sns_endpoint"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.custom_vpc_id

  tags = {
    Name = "allow_tls_sns_endpoint"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sns_ingress_from_lambda" {
  security_group_id        = aws_security_group.serverless_sns_endpoint_sg.id
  ip_protocol              = "tcp"
  from_port                = 443
  to_port                  = 443
  referenced_security_group_id = aws_security_group.serverless_lambda_sg.id
}


resource "aws_vpc_security_group_egress_rule" "example_sns" {
  security_group_id = aws_security_group.serverless_sns_endpoint_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}