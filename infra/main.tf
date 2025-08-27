# module "serverless_s3_creation" {
#   source        = "./modules/s3"
#   bucket_name   = "my-unique-bucket-name-umer-12345-29"

#   tags = {
#     Name        = "MyBucket"
#     Environment = "Dev"
#   }
# }

module "serverless_custom_vpc" {
  source        = "./modules/networking"
  cidr_block    = "10.0.0.0/16"
  public_subnet = "10.0.1.0/24"
  private_subnet = "10.0.2.0/24"
  serverless_security_group_id = module.serverless_sg.serverless_security_group_id
  serverless_sns_security_group_id = module.serverless_sg.serverless_security__sns_group_id

}


module "serverless_iam" {
  source        = "./modules/iam"
  bucket_name   = "my-unique-bucket-name-umer-12345-29"
  # aws_dynamodb_table = module.serverless_dynamodb.serverless_dynamodb_table_arn
  # aws_sns_arn = module.serverless_sns.serverless_aws_sns_arn

}

module "serverless_sg" {
  source        = "./modules/securityGroup"
  custom_vpc_id = module.serverless_custom_vpc.custom_vpc_id
}

module "serverless_lambda" {
  source        = "./modules/Lambda"
  lambda_assume_role = module.serverless_iam.iam_role_arn
  serverless_private_subnet_id = module.serverless_custom_vpc.serverless_private_subnet_id

  serverless_security_group_id = module.serverless_sg.serverless_security_group_id
}


# module "serverless_dynamodb" {
#   source        = "./modules/dynamoDB"
# }


# module "serverless_cognito" {
#   source        = "./modules/cognito"
# }

# module "serverless_api_gateway" {
#   source        = "./modules/api-gateaway"
#   lambda_function_name = module.serverless_lambda.lambda_function_name
#   lambda_function_invoke_arn = module.serverless_lambda.lambda_function_invoke_arn
#   serverless_cognito_client_id = module.serverless_cognito.serverless_cognito_client_id
#   serverless_cognito_pool_endpoint = module.serverless_cognito.serverless_cognito_pool_endpoint
# }


# module "serverless_sns" {
#   source        = "./modules/sns"
# }