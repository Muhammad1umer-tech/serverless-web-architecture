resource "aws_s3_bucket" "serverless_my_bucket" {
  bucket = var.bucket_name
  tags = var.tags
}
