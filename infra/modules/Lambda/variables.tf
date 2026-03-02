variable "project_name" { type = string }
variable "environment"  { type = string }

variable "lambda_assume_role"             { type = string }
variable "private_subnet_id"               { type = string }
variable "security_group_id"               { type = string }

variable "table_name"     { type = string }
variable "bucket_name"    { type = string }
variable "file_key"       { type = string }
variable "sns_topic_arn"  { type = string }

variable "application_secret_arn" {
  type        = string
  description = "Secrets Manager secret ARN passed to Lambda"
}