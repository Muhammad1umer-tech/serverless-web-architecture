resource "aws_secretsmanager_secret" "infra_names" {
  name        = "infra-resource-names"
  description = "Stores names of critical AWS infrastructure resources"
}

resource "aws_secretsmanager_secret_version" "infra_names_version" {
  secret_id     = aws_secretsmanager_secret.infra_names.id
  secret_string = jsonencode({
    s3_bucket_name   = aws_s3_bucket.my_bucket.id
    dynamodb_table   = aws_dynamodb_table.my_table.name
  })
}
