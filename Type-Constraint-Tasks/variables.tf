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
