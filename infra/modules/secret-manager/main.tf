resource "aws_secretsmanager_secret" "admin_config" {
  name = "${var.project_name}-${var.environment}-admin-config"
}

resource "aws_secretsmanager_secret_version" "admin_config_value" {
  secret_id = aws_secretsmanager_secret.admin_config.id

  secret_string = jsonencode({
    admin_email = var.admin_email
  })
}

output "admin_secret_arn" {
  value = aws_secretsmanager_secret.admin_config.arn
}