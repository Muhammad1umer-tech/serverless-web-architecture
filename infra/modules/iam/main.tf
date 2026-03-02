######################
# Trust policy — allows Lambda service to assume this role
######################
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

######################
# Permission policy — defines what Lambda can access
######################
data "aws_iam_policy_document" "lambda_execution_policy_document" {

  # Required for Lambda inside VPC (ENI management)
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses"
    ]
    resources = ["*"]
  }

  # S3 access
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }

  # DynamoDB access
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]
    resources = [var.dynamodb_table_arn]
  }

  # SNS publish permission
  statement {
    effect = "Allow"
    actions = ["sns:Publish"]
    resources = [var.sns_topic_arn]
  }
  
  # Secrets Manager permission
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [var.application_secret_arn]
  }
}

######################
# Register upper custom policy in AWS
######################
resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "${var.project_name}-${var.environment}-lambda-execution-policy"
  description = "Execution policy for Lambda (VPC + S3 + DynamoDB + SNS)"
  policy      = data.aws_iam_policy_document.lambda_execution_policy_document.json
}

######################
# Create IAM Role for Lambda (Add assumerole in role)
######################
resource "aws_iam_role" "lambda_execution_role" {
  name               = "${var.project_name}-${var.environment}-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

######################
# Attach AWS managed logging policy with policy
######################
resource "aws_iam_role_policy_attachment" "lambda_basic_logging_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

######################
# Attach custom execution policy along with basic logging policy
######################
resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}