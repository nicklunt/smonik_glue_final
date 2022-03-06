resource "aws_vpc_endpoint" "smonik_ep" {
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
      Version = "2008-10-17"
    }
  )

  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-west-2.s3"

  tags = {
    "Name" = "nl-smonik"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.this.id

  # This route only added to allow route to my IP via IGW.
  # Changed to 0.0.0.0/0 so instances can access www.
  route {
    # cidr_block = var.allowed_rdp_ips
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  # Can add more than one route
  # route {
  #   cidr_block = "1.2.3.4/16"
  #   transit_gateway_id = "tgw-lskdjfkldj"
  # }

  tags = {
    Name = "nl-smonik"
  }
}

resource "aws_route_table_association" "az1a" {
  subnet_id      = aws_subnet.az1a.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "az1b" {
  subnet_id      = aws_subnet.az1b.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_vpc_endpoint_route_table_association" "eprta" {
  route_table_id  = aws_route_table.rt.id
  vpc_endpoint_id = aws_vpc_endpoint.smonik_ep.id
}

# TRYING SHIT OUT
# data "aws_prefix_list" "s3_prefix" {
#   prefix_list_id = aws_vpc_endpoint.smonik_ep.prefix_list_id
# }

# resource "aws_route_table" "rtb" {
#   vpc_id = aws_vpc.this.id
# }



# resource "aws_vpc_endpoint_subnet_association" "a" {
#   vpc_endpoint_id = aws_vpc_endpoint.smonik_ep.id
#   subnet_id = aws_subnet.az1a.id
# }

# resource "aws_vpc_endpoint_subnet_association" "b" {
#   vpc_endpoint_id = aws_vpc_endpoint.smonik_ep.id
#   subnet_id = aws_subnet.az1b.id
# }
