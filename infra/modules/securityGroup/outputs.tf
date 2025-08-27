output "serverless_security_group_id" {
  value = aws_security_group.serverless_lambda_sg.id
}

output "serverless_security__sns_group_id" {
  value = aws_security_group.serverless_sns_endpoint_sg.id
}

