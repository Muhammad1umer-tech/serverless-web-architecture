variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet" {
  description = "Public subnet IP range"
  type        = string
}

variable "private_subnet" {
  description = "Private subnet IP range"
  type        = string
}

variable "serverless_security_group_id" {
    type = string
}

variable "serverless_sns_security_group_id" {
    type = string
}

