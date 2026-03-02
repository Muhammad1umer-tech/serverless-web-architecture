############################
# Lambda Security Group
# - Attached to Lambda ENIs in private subnet
# - Allows outbound HTTPS to AWS services (via endpoints/NAT if present)
############################
resource "aws_security_group" "lambda_execution_sg" {
  name        = "${var.project_name}-${var.environment}-lambda-sg"
  description = "Security group for Lambda execution in private subnet"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Allow all outbound (common for Lambda). You can restrict later if desired.
resource "aws_vpc_security_group_egress_rule" "lambda_all_egress" {
  security_group_id = aws_security_group.lambda_execution_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

############################
# SNS Interface Endpoint Security Group
# - Attached to the SNS VPC Interface Endpoint ENI
# - Allows inbound 443 ONLY from Lambda SG
############################
resource "aws_security_group" "sns_endpoint_sg" {
  name        = "${var.project_name}-${var.environment}-sns-endpoint-sg"
  description = "Security group for SNS interface VPC endpoint"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-sns-endpoint-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Inbound HTTPS from Lambda SG to SNS endpoint
resource "aws_vpc_security_group_ingress_rule" "sns_https_from_lambda" {
  security_group_id             = aws_security_group.sns_endpoint_sg.id
  ip_protocol                   = "tcp"
  from_port                     = 443
  to_port                       = 443
  referenced_security_group_id  = aws_security_group.lambda_execution_sg.id
}

# Egress: allow all (safe/standard for endpoint SG; can tighten later)
resource "aws_vpc_security_group_egress_rule" "sns_endpoint_all_egress" {
  security_group_id = aws_security_group.sns_endpoint_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}