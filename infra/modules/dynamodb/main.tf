resource "aws_dynamodb_table" "application_data_table" {
  name         = "${var.project_name}-${var.environment}-qa-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Id"

  attribute {
    name = "Id"
    type = "S"
  }

  # Optional but recommended for better querying by question
  attribute {
    name = "question"
    type = "S"
  }

  global_secondary_index {
    name            = "QuestionIndex"
    hash_key        = "question"
    projection_type = "ALL"
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-qa-table"
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}