resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.network_identifier
  }
}

locals {
  subnet_cidr_blocks = {
    for i, az in sort(tolist(var.availability_zones)) : az => {
      public : cidrsubnet(var.vpc_cidr_block, 4, 2 * i),
      private : cidrsubnet(var.vpc_cidr_block, 4, 2 * i + 1)
    }
  }
}
