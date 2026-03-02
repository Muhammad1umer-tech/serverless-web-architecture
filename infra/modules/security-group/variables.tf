variable "project_name" { type = string }
variable "environment"  { type = string }

variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"
}