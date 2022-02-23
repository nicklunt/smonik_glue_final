terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.55"
    }
  }
  # required_version = "= 1.0.1"
}

provider "aws" {
  # region = "us-east-1"
  region = "eu-west-2"

  default_tags {
    tags = {
      Environment = var.environment
      Product     = var.name
    }
  }
}

