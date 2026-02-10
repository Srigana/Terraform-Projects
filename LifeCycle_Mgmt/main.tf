resource "aws_instance" "my_instance" {
  instance_type = var.instance_type[0]
  ami           = ami-0ff8a91507f77f867

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket" "lifecycle_mgmt_bucket" {
  bucket = var.bucket_name
  tags   = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

