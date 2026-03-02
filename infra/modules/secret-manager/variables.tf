variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}

variable "admin_email" {
  description = "Admin email stored securely in Secrets Manager"
  type        = string
}