locals {
  common_tags = {
    Environment = var.environment
    Owner       = "Srigana"
    Project     = "Key"
  }

  bucket_name = "${var.environment}-${var.bucket_name}-${random_string.suffix.result}"
  region      = var.region
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}
