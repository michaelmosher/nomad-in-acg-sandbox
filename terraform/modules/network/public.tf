resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.network_identifier
  }
}

resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = var.network_identifier
  }
}

resource "aws_subnet" "public" {
  for_each = var.availability_zones

  availability_zone       = each.value
  cidr_block              = local.subnet_cidr_blocks[each.value].public
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name = "${var.network_identifier} - public"
    Tier = "public"
  }
}
