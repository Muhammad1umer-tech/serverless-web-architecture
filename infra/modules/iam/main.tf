######################
# IAM Assume policy
######################


data "aws_iam_policy_document" "assume_role_for_lambda" {
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
# IAM Policy Document
######################


data "aws_iam_policy_document" "serverless_additional_policy_doc_lambda" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }

  # statement {
  #   effect = "Allow"
  #   actions = [
  #     "dynamodb:Scan",
  #     "dynamodb:Query",
  #     "dynamodb:GetItem",
  #     "dynamodb:PutItem"
  #   ]
  #   resources = [
  #     var.aws_dynamodb_table
  #   ]
  # }

  # statement {
  #   effect = "Allow"
  #   actions = [
  #     "sns:Publish",
  #   ]
  #   resources = [
  #     var.aws_sns_arn
  #   ]
  # }
}

######################
# IAM Policy
######################

resource "aws_iam_policy" "serverless_policy_lambda" {
  name        = "test_policy"
  description = "My test policy"
  policy = data.aws_iam_policy_document.serverless_additional_policy_doc_lambda.json
}

######################
# IAM Role
######################

resource "aws_iam_role" "serverless_iam_for_lambda" {
  name               = "lambda_hello_world_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_for_lambda.json
}

######################
# POlicy and Role attachement
######################


resource "aws_iam_role_policy_attachment" "lambda_assume_role" {
  role       = aws_iam_role.serverless_iam_for_lambda.name
  policy_arn = aws_iam_policy.serverless_policy_lambda.arn
}