variable "project_name" { type = string }
variable "environment"  { type = string }

variable "bucket_name"  { type = string }
variable "dynamodb_table_arn" { type = string }
variable "sns_topic_arn" { type = string }

variable "application_secret_arn" {
  type        = string
  description = "ARN of the secret in AWS Secrets Manager"
}