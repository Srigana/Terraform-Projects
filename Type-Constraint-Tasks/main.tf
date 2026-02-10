provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "new-bucket" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

resource "aws_instance" "my-instance" {
  count                       = var.instance_count
  ami                         = "ami-0c55b159cbfafe1f0"
  monitoring                  = var.monitoring_enabled
  associate_public_ip_address = var.associate_public_ip
  instance_type               = var.instance_type
  lifecycle {
    precondition {
      condition     = contains(var.vm_types, var.instance_type)
      error_message = "Instance type is not allowed"
    }
  }
}

resource "aws_vpc" "new_vpc" {
  cidr_block = var.cidr_block[0]
  tags       = var.instance_tags
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.new_vpc.id
  cidr_block = var.cidr_block[1]
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.new_vpc.id
  cidr_block = var.cidr_block[2]
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  from_port         = var.ingress_values[0]
  to_port           = var.ingress_values[2]
  ip_protocol       = var.ingress_values[1]
  cidr_ipv4         = var.cidr_block[0]
}

