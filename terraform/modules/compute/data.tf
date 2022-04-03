data "aws_ami" "centos_9" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Stream 9*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Offical account for RedHat's "Community Platform Engineering" team.
  # Ref: https://wiki.centos.org/Cloud/AWS
  owners = ["125523088429"]
}
