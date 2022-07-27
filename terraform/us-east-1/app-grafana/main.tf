resource "aws_ebs_volume" "this" {
  # availability_zone = data.aws_subnet.selected.availability_zone
  availability_zone = "us-east-1a"
  size              = 10
}
