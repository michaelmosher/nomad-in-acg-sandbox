data "cloudinit_config" "coordinator_user_data" {
  gzip          = true
  base64_encode = true

  dynamic "part" {
    for_each = fileset("${var.cloud_init_files_path}/cluster-coordinator/", "*.yml")

    content {
      content_type = "text/jinja2"
      content      = file("${var.cloud_init_files_path}/cluster-coordinator/${part.value}")
      filename     = part.value
    }
  }

  part {
    content_type = "text/cloud-config"
    filename     = "configure_consul_server.yml"

    content = templatefile(
      "${var.cloud_init_files_path}/templates/configure_consul_server.tftpl",
      {
        datacenter       = var.cluster_identifier,
        bootstrap_expect = var.coordinator_instance_count,
      }
    )
  }

  part {
    content_type = "text/cloud-config"
    filename     = "configure_nomad_server.yml"

    content = templatefile(
      "${var.cloud_init_files_path}/templates/configure_nomad_server.tftpl",
      {
        datacenter       = var.cluster_identifier,
        bootstrap_expect = var.coordinator_instance_count,
      }
    )
  }
}

resource "aws_instance" "cluster_coordinators" {
  ami                  = data.aws_ami.centos_9.id
  iam_instance_profile = var.coordinator_instance_profile
  instance_type        = var.coordinator_instance_type
  user_data            = data.cloudinit_config.coordinator_user_data.rendered

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

  lifecycle {
    ignore_changes = [ami]
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
