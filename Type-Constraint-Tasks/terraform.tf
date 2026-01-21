terraform {
  required_providers {
    aws = {
      source  = "hasicorp/aws"
      version = "~>3.1"
    }
    random = {
      source  = "hasicorp/random"
      version = "~>3.1"
    }
  }
  required_version = ">=1.2"
}
