resource "aws_default_vpc" "default" {
  force_destroy = true

  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default" {
  for_each = toset(data.aws_availability_zones.available.names)
  availability_zone = each.key
  force_destroy = true

  tags = {
    Name = "Default subnet for ${each.key}"
  }
}


resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_default_vpc.default.default_network_acl_id
  subnet_ids = [ for subnet in aws_default_subnet.default : subnet.id ]

  tags = {
    Name = "Default network ACL"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_default_vpc.default.default_route_table_id

  tags = {
    Name = "Default route table"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id

  tags = {
    Name = "Default security group"
  }
}

resource "aws_default_vpc_dhcp_options" "default" {
  depends_on = [aws_default_vpc.default]
  tags = {
    Name = "Default DHCP options"
  }
}