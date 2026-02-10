variable "project_name" {
  default = "Project name"
}

variable "environment_tags" {
  default = {
    environment = "dev"
    cost_center = "cc-123"
  }
}

variable "default_tags" {
  default = {
    company    = "Terraform"
    managed_by = "Hashicorp"
  }
}

variable "bucket_name" {
  default = "ProjectAlphaStorageBucket with CAPS and SPACES!!!"
}
