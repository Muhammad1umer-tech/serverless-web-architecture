output "lambda_security_group_id" {
  description = "Security group ID for Lambda execution"
  value       = aws_security_group.lambda_execution_sg.id
}

output "sns_endpoint_security_group_id" {
  description = "Security group ID for SNS interface endpoint"
  value       = aws_security_group.sns_endpoint_sg.id
}