data "aws_route53_zone" "public" {
  name         = local.cloud_lab_dns
  private_zone = false
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [local.network_id]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${local.network_id} - private"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${local.network_id} - public"]
  }
}
