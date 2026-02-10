output "bucket_names_using_count" {
  description = "Printing bucket names using count"
  value       = aws_s3_bucket.bucket_one[*].id
}

output "bucket_names_using_for_each" {
  description = "Printing bucket names using for each"
  value       = [for i in aws_s3_bucket.bucket_two : i.id]
}

output "bucket_id_and_names_using_for" {
  description = "Printing bucket ids and names using for loop"
  value = {
    for key, bucket in aws_s3_bucket.bucket_two :
    key => {
      id     = bucket.id
      bucket = bucket.bucket
    }
  }
}
