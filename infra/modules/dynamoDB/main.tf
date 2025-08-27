resource "aws_dynamodb_table" "serverless_dynamodb_table" {
  name             = "serverless_dynamodb_table"
  hash_key         = "Id"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "Id"
    type = "S"
  }
}