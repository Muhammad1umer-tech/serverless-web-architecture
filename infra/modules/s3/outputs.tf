output "storage_bucket_name" {
  description = "Name of the S3 storage bucket"
  value       = aws_s3_bucket.application_storage_bucket.bucket
}

output "storage_bucket_arn" {
  description = "ARN of the S3 storage bucket"
  value       = aws_s3_bucket.application_storage_bucket.arn
}