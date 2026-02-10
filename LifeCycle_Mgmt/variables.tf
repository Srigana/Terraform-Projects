variable "environmnet" {
  description = "The environmnet"
  type        = string
  default     = "stage"
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default = {
    Environmnet = var.environmnet
    Owner       = "Terraform team"
    Project     = "Infrastructure"
  }
}

variable "bucket_name" {
  description = "The name of the S3 bucket to store lifecycle management data."
  type        = string
  default     = "${var.environment}-${random_string.buckt_suffix.result}-lifecycle-mgmt"
}

resource "random_string" "bucket_suffix" {
  length  = 5
  upper   = false
  special = false
}

variable "instance_type" {
  description = "The type of instance to use for the EC2 instance."
  type        = list(string)
  default = [
    "t2.micro",
    "t3.micro"
  ]
}
