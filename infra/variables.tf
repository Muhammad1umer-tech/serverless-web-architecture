variable "project_name" { type = string }
variable "admin_email"  { type = string }

variable "environment"  { type = string }
variable "table_name"   { type = string }
variable "bucket_name"  { type = string }
variable "file_key"     { type = string }

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for private subnet"
}