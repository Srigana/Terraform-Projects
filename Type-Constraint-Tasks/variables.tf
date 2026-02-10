variable "environment" {
  type    = string
  default = "dev"
}

variable "bucket_name" {
  type    = string
  default = "dev-resource-name"
}

variable "region" {
  type    = string
  default = "us-east-1"
  validation {
    condition     = contains(var.allowed_regions, var.region)
    error_message = "The specified region is not allowed. Please choose an approved region."
  }
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "monitoring_enabled" {
  type    = bool
  default = false
}

variable "associate_public_ip" {
  type    = bool
  default = false
}

variable "cidr_block" {
  type = list(string)
  default = [
    "10.0.0.0/8",
    "192.168.0.0/16",
    "172.16.0.0/12"
  ]
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vm_types" {
  type = list(string)
  default = [
    "t2.micro",
    "t2.small",
    "t3.micro",
    "t3.small"
  ]
}

variable "allowed_regions" {
  type = set(string)
  default = [
    "us-east-1",
    "us-west-2",
    "eu-west-1"
  ]
}

variable "instance_tags" {
  type = map(string)
  default = {
    Environment = "dev",
    Name        = "dev-Instance",
    created_by  = "terraform"
  }
}

variable "ingress_values" {
  type    = tuple([number, string, number])
  default = [443, "tcp", 443]
}

variable "constraint_configs" {
  type = object({
    region         = string,
    monitoring     = bool,
    instance_count = number
  })
  default = {
    region         = "us-east-1",
    monitoring     = true,
    instance_count = 1
  }
}
