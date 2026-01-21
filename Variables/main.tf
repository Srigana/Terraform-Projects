resource "aws_s3_bucket" "another_bucket" {
  bucket = local.my-bucket-name
  tags   = local.common_tags
}
