locals {
  common_tags = {
    Environment = "var.environment"
    Project     = "DevOps"
    Owner       = "Srigana"
  }
  my-bucket-name = "${var.environment}-${var.bucket_name}-${random_string.name.result}"
}

resource "random_string" "name" {
  length  = 6
  special = false
  upper   = false
}
