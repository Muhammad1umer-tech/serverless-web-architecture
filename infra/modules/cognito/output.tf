output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.application_user_pool.id
}

output "cognito_user_pool_client_id" {
  description = "Cognito App Client ID"
  value       = aws_cognito_user_pool_client.application_app_client.id
}

output "cognito_user_pool_endpoint" {
  description = "Cognito User Pool Endpoint"
  value       = aws_cognito_user_pool.application_user_pool.endpoint
}