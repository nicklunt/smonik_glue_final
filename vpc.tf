# VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "smonik-${var.environment} application"
  }
}

# Data Subnets
resource "aws_subnet" "az1a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.data_subnet_cidr_az1a
  availability_zone = "eu-west-2a"

  tags = {
    Name = "nl-${var.environment}-${var.region_short_name}-X-az1-sub-smonik-data-z"
  }
}

resource "aws_subnet" "az1b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.data_subnet_cidr_az1b
  availability_zone = "eu-west-2b"

  tags = {
    Name = "nl-${var.environment}-${var.region_short_name}-X-az2-sub-smonik-data-z"
  }
}

resource "aws_subnet" "web1" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.web_subnet_cidr
  # availability_zone = "eu-west-2b"

  tags = {
    Name = "nl-${var.environment}-${var.region_short_name}-X-az1-sub-smonik-web-z"
  }
}

# Gateway so we can RDP to it
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "nl-ig"
  }
}

# resource "aws_route_table" "this" {
#   vpc_id = aws_vpc.this.id

#   route {
#     # cidr_block = "0.0.0.0/0"
#     cidr_block = var.allowed_rdp_ips
#     gateway_id = aws_internet_gateway.this.id
#   }

#   tags = {
#     Name = "nl-route-table"
#   }
# }

# resource "aws_route_table_association" "az1a_gw" {
#   # subnet_id      = aws_subnet.az1a.id
#   gateway_id = aws_internet_gateway.this.id
#   # route_table_id = aws_route_table.this.id
#   route_table_id = aws_route_table.rt.id
# }

# resource "aws_route_table_association" "az1b_gw" {
#   # subnet_id      = aws_subnet.az1b.id
#   gateway_id = aws_internet_gateway.this.id
#   # route_table_id = aws_route_table.this.id
#   route_table_id = aws_route_table.rt.id
# }

# resource "aws_vpc_endpoint" "s3" {
#   policy = jsonencode(
#     {
#       Statement = [
#         {
#           Action    = "*"
#           Effect    = "Allow"
#           Principal = "*"
#           Resource  = "*"
#         },
#       ]
#       Version = "2008-10-17"
#     }
#   )
#   # private_dns_enabled = false
#   # private_dns_enabled = true
#   # route_table_ids     = []
#   service_name      = "com.amazonaws.eu-west-2.s3"
#   vpc_endpoint_type = "Gateway"
#   vpc_id            = aws_vpc.this.id
#   auto_accept = true

#   tags = {
#     "Name" = "nl-smonik-s3-gateway-endpoint"
#   }
# }

