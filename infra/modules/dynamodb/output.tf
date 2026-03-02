output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.application_data_table.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.application_data_table.arn
}