variable "environment" {
  description = "The environment for the resources"
  type        = string
  default     = "staging"
}

variable "bucket_name" {
  description = "The base name for the S3 bucket"
  type        = string
  default     = "my-buck"
}
