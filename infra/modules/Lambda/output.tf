output "lambda_names" {
  value = { for k, v in aws_lambda_function.lambda : k => v.function_name }
}

output "lambda_invoke_arns" {
  value = { for k, v in aws_lambda_function.lambda : k => v.invoke_arn }
}