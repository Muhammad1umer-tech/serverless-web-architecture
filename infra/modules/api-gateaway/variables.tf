variable "project_name" { type = string }
variable "environment"  { type = string }

variable "add_lambda_name"        { type = string }
variable "query_lambda_name"      { type = string }

variable "add_lambda_invoke_arn"  { type = string }
variable "query_lambda_invoke_arn" { type = string }

variable "cognito_client_id" { type = string }
variable "cognito_user_pool_endpoint" { type = string }