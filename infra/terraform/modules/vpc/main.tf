resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource random_id index {
  byte_length = 2
}

locals {
  az_names              = keys(var.main_public_subnet_cidrs)
  az_names_random_index = random_id.index.dec % length(local.az_names)
}

resource "aws_eip" "nat" {
  vpc  = true
  tags = {
    Name = "Main NAT"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.main_public[local.az_names[local.az_names_random_index]].id

  tags = {
    Name = "Main NAT"
  }
}

resource "aws_route" "main-nat" {
  route_table_id         = aws_vpc.main.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Main public"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = var.additional_public_subnet_cidrs
  route_table_id = aws_route_table.public.id
  subnet_id      = concat(aws_subnet.additional_public[each.key].id, aws_subnet.main_public[each.key].id)
}

resource "aws_subnet" "additional_private" {
  for_each = var.additional_private_subnet_cidrs

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = false

  tags = {
    Name             = each.value.name
    AvailabilityZone = each.key
  }
}

resource "aws_subnet" "main_private" {
  for_each = var.main_private_subnet_cidrs

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name             = "Main private subnet for ${each.key}"
    AvailabilityZone = each.key
  }
}

resource "aws_subnet" "additional_public" {
  for_each = var.additional_public_subnet_cidrs

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = true

  tags = {
    Name             = each.value.name
    AvailabilityZone = each.key
  }
}

resource "aws_subnet" "main_public" {
  for_each = var.main_public_subnet_cidrs

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name             = "Main public subnet for ${each.key}"
    AvailabilityZone = each.key
  }
}

resource "aws_vpc_endpoint" "aws_services" {
  for_each = var.aws_service_endpoints

  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type = each.value
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "Service endpoint for ${each.key} in ${data.aws_region.current.name}"
  }
}

