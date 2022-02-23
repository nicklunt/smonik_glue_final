# VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "smonik-${var.environment} application"
  }
}

# Data Subnets
resource "aws_subnet" "az1a" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.data_subnet_cidr_az1a
  # availability_zone = "us-east-1a"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "nl-${var.environment}-${var.region_short_name}-X-az1-sub-smonik-data-z"
  }
}

resource "aws_subnet" "az1b" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.data_subnet_cidr_az1b
  #  = "us-east-1b"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "nl-${var.environment}-${var.region_short_name}-X-az2-sub-smonik-data-z"
  }
}



