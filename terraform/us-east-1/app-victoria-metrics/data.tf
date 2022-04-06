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

data "aws_security_group" "workers" {
  vpc_id = data.aws_vpc.main.id

  filter {
    name   = "tag:Name"
    values = ["${local.cluster_id}-cluster-workers"]
  }
}
