resource "aws_instance" "cluster_coordinators" {
  ami                  = data.aws_ami.my_centos_9.id
  iam_instance_profile = var.coordinator_instance_profile
  instance_type        = var.coordinator_instance_type
  user_data            = var.coordinator_user_data

  subnet_id = element(
    [for s in var.cluster_subnet_ids : s], # turn set into ordered list
    count.index % length(var.cluster_subnet_ids)
  )

  vpc_security_group_ids = [
    aws_security_group.cluster_coordinators.id,
    aws_security_group.gossip.id,
  ]

  tags = {
    Name             = format("%s-coordinator-%d", var.cluster_identifier, count.index + 1)
    ConsulDatacenter = var.cluster_identifier
  }

  count = var.coordinator_instance_count
}

resource "aws_lb_target_group" "consul" {
  name     = "${var.cluster_identifier}-consul"
  port     = 8500
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/v1/status/leader"
  }
}

resource "aws_lb_target_group_attachment" "consul" {
  target_group_arn = aws_lb_target_group.consul.arn
  target_id        = aws_instance.cluster_coordinators[count.index].id
  count            = var.coordinator_instance_count
}

resource "aws_lb_target_group" "nomad" {
  name     = "${var.cluster_identifier}-nomad"
  port     = 4646
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/v1/status/leader"
  }
}

resource "aws_lb_target_group_attachment" "nomad" {
  target_group_arn = aws_lb_target_group.nomad.arn
  target_id        = aws_instance.cluster_coordinators[count.index].id
  count            = var.coordinator_instance_count
}
