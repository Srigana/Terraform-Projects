provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "merging" {
  bucket = local.formatted_bucket_name
  tags   = local.new_tags
}
