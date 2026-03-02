module "application_storage" {
  source       = "./modules/s3"
  project_name = var.project_name
  environment  = var.environment
  bucket_name  = var.bucket_name
}

module "application_network" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr

  sns_endpoint_security_group_id = module.application_security_groups.sns_endpoint_security_group_id
}


module "application_policies" {
  source             = "./modules/iam"
  project_name       = var.project_name
  environment        = var.environment

  bucket_name        = var.bucket_name
  dynamodb_table_arn = module.application_database.dynamodb_table_arn
  sns_topic_arn      = module.application_sns.sns_topic_arn
  application_secret_arn = module.application_secrets_manager.application_secret_arn
}

module "application_lambda" {
  source                       = "./modules/Lambda"
  lambda_assume_role           = module.application_policies.iam_role_arn
  private_subnet_id            = module.application_network.private_subnet_id
  security_group_id             = module.application_security_groups.lambda_security_group_id

  # required inputs for your Lambda module
  project_name = var.project_name
  environment  = var.environment
  table_name   = var.table_name
  bucket_name  = var.bucket_name
  file_key     = var.file_key

  # sns
  sns_topic_arn = module.application_sns.sns_topic_arn
  application_secret_arn = module.application_secrets_manager.application_secret_arn
}


module "application_sns" {
  source       = "./modules/sns"
  project_name = var.project_name
  admin_email  = var.admin_email
}

module "application_database" {
  source       = "./modules/dynamodb"
  project_name = var.project_name
  environment  = var.environment
}

module "application_cognito" {
  source        = "./modules/cognito"
  project_name  = var.project_name
  environment   = var.environment
}


module "application_api" {
  source = "./modules/api-gateaway"

  project_name = var.project_name
  environment  = var.environment

  add_lambda_name       = module.application_lambda.lambda_names["addLambda"]
  query_lambda_name     = module.application_lambda.lambda_names["queryLambda"]

  add_lambda_invoke_arn   = module.application_lambda.lambda_invoke_arns["addLambda"]
  query_lambda_invoke_arn = module.application_lambda.lambda_invoke_arns["queryLambda"]

  cognito_client_id           = module.application_cognito.cognito_user_pool_client_id
  cognito_user_pool_endpoint  = module.application_cognito.cognito_user_pool_endpoint
}


module "application_security_groups" {
  source       = "./modules/security-group"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.application_network.vpc_id
}

module "application_secrets_manager" {
  source       = "./modules/secret-manager"
  project_name = var.project_name
  environment  = var.environment
  admin_email  = var.admin_email
}