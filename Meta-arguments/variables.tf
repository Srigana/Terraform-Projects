variable "bucket_names" {
  type        = list(string)
  default     = ["bucket-one-o-one", "bucket-two-o-two", "bucket-three-o-three"]
  description = "Bucket names"
}

variable "environment" {
  type        = string
  default     = "Dev"
  description = "Environment name"
}

variable "bucket_names_set" {
  type        = set(string)
  default     = ["bucket-set-one", "bucket-set-two", "bucket-set-three"]
  description = "Set of bucket names"
}
