locals {
  lambda_functions = {
    addLambda   = "${path.root}/lambda/addLambda"
    queryLambda = "${path.root}/lambda/queryLambda"
  }

  common_env = {
    TABLE_NAME  = var.table_name
    BUCKET_NAME = var.bucket_name
    FILE_KEY    = var.file_key
    TOPIC_ARN   = var.sns_topic_arn
    APP_SECRET_ARN = var.application_secret_arn
  }
}