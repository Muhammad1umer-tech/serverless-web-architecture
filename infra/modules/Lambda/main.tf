data "archive_file" "lambda_zip" {
  for_each    = local.lambda_functions
  type        = "zip"
  source_dir  = each.value
  output_path = "${path.module}/build/${each.key}.zip"
}

resource "aws_lambda_function" "lambda" {
  for_each      = local.lambda_functions
  function_name = "${var.project_name}-${each.key}"
  runtime       = "python3.12"
  role          = var.lambda_assume_role
  handler       = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip[each.key].output_path
  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256

  environment {
    variables = local.common_env
  }

  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [var.security_group_id]
  }

  tags = {
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Environment = var.environment
  }
}