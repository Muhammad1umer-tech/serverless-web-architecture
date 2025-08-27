data "archive_file" "serverless_archive_file" {
  for_each    = local.lambda_functions
  type        = "zip"
  source_dir  = each.value
  output_path = "${path.module}/build/${each.key}.zip"
}

resource "aws_lambda_function" "test_lambda" {
  for_each         = local.lambda_functions
  function_name    = each.key
  runtime          = "python3.12"
  role             = var.lambda_assume_role
  handler          = "lambda_function.lambda_handler"
  
  filename         = data.archive_file.serverless_archive_file[each.key].output_path
  source_code_hash = data.archive_file.serverless_archive_file[each.key].output_base64sha256

  environment {
    variables = {
      foo = "bar"
    }
  }

  #When you specify subnet_ids, AWS will create ENIs inside those subnets for your Lambda function.
  #When you specify security_group_ids, AWS attaches those security groups to the ENIs it creates for your Lambda.
  vpc_config {
    subnet_ids = [var.serverless_private_subnet_id]
    security_group_ids = [var.serverless_security_group_id]
  }
}