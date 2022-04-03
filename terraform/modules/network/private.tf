resource "aws_eip" "nat_gateway" {
  for_each = var.availability_zones
  vpc      = true

  tags = {
    Name = "${var.network_identifier} - nat gateway - ${each.value}"
  }
}

resource "aws_nat_gateway" "main" {
  for_each = var.availability_zones

  allocation_id = aws_eip.nat_gateway[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${var.network_identifier} - ${each.value}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  for_each = var.availability_zones

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[each.key].id
  }

  tags = {
    Name = "${var.network_identifier} - private"
    Tier = "private"
  }
}

resource "aws_subnet" "private" {
  for_each = var.availability_zones

  availability_zone = each.value
  cidr_block        = local.subnet_cidr_blocks[each.value].private
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "${var.network_identifier} - private"
    Tier = "private"
  }
}

resource "aws_route_table_association" "private" {
  for_each = var.availability_zones

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
