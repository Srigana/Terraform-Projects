output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.another_bucket.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 Bucket"
  value       = aws_s3_bucket.another_bucket.arn
}

output "environment" {
  description = "Environment of the resource"
  value       = var.environment
}

output "tags" {
  description = "Tags applied to the S3 bucket"
  value       = local.common_tags
}
