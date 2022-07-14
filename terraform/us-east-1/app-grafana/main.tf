resource "aws_ebs_volume" "this" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = 10
}
