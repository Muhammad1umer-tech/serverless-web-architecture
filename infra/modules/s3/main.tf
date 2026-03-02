############################
# S3 Bucket
############################

resource "aws_s3_bucket" "application_storage_bucket" {
  bucket = var.bucket_name

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-storage"
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

############################
# Block Public Access
############################

resource "aws_s3_bucket_public_access_block" "application_storage_public_access_block" {
  bucket = aws_s3_bucket.application_storage_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################
# Enable Versioning
############################

resource "aws_s3_bucket_versioning" "application_storage_versioning" {
  bucket = aws_s3_bucket.application_storage_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

############################
# Enable Server-Side Encryption
############################

resource "aws_s3_bucket_server_side_encryption_configuration" "application_storage_encryption" {
  bucket = aws_s3_bucket.application_storage_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}