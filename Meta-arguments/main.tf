resource "aws_s3_bucket" "bucket_one" {
  count  = length(var.bucket_names)
  bucket = "${var.bucket_names[count.index]}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = var.bucket_names[count.index]
    Environment = var.environment
    Index       = count.index
    ManagedBy   = "Terraform"
  }
}
resource "aws_s3_bucket" "bucket_two" {
  for_each = var.bucket_names_set
  bucket   = "${each.key}-${random_string.bucket_suffix.result}"
  tags = {
    Name        = each.key
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}
