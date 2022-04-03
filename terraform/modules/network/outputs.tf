output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr_block" {
  value = var.vpc_cidr_block
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}
