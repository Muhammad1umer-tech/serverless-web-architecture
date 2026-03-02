output "application_secret_arn" {
  description = "ARN of the application secret"
  value       = aws_secretsmanager_secret.admin_config.arn
}

output "application_secret_name" {
  description = "Name of the application secret"
  value       = aws_secretsmanager_secret.admin_config.name
}