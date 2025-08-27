output "serverless_cognito_client_id" {
  value = aws_cognito_user_pool_client.serverless_app_client.id
}

output "serverless_cognito_pool_id" {
  value = aws_cognito_user_pool.serverless_user_pool.id
}

output "serverless_cognito_pool_endpoint" {
  value = aws_cognito_user_pool.serverless_user_pool.endpoint
}

