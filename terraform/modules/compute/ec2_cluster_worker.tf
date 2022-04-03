data "cloudinit_config" "worker_user_data" {
  gzip          = true
  base64_encode = true

  dynamic "part" {
    for_each = fileset("${var.cloud_init_files_path}/cluster-worker/", "*.yml")

    content {
      content_type = "text/jinja2"
      content      = file("${var.cloud_init_files_path}/cluster-worker/${part.value}")
      filename     = part.value
    }
  }

  part {
    content_type = "text/cloud-config"
    filename     = "configure_consul_agent.yml"

    content = templatefile(
      "${var.cloud_init_files_path}/templates/configure_consul_agent.tftpl",
      {
        datacenter = var.cluster_identifier,
      }
    )
  }

  part {
    content_type = "text/cloud-config"
    filename     = "configure_nomad_agent.yml"

    content = templatefile(
      "${var.cloud_init_files_path}/templates/configure_nomad_agent.tftpl",
      {
        datacenter = var.cluster_identifier,
      }
    )
  }
}

resource "aws_instance" "cluster_worker" {
  ami                  = data.aws_ami.centos_9.id
  iam_instance_profile = var.worker_instance_profile
  instance_type        = var.worker_instance_type
  user_data            = data.cloudinit_config.worker_user_data.rendered

  subnet_id = element(
    [for s in var.cluster_subnet_ids : s], # turn set into ordered list
    count.index % length(var.cluster_subnet_ids)
  )

  vpc_security_group_ids = [
    aws_security_group.cluster_workers.id,
    aws_security_group.gossip.id,
  ]

  tags = {
    Name             = format("%s-worker-%d", var.cluster_identifier, count.index + 1)
    ConsulDatacenter = var.cluster_identifier
  }

  lifecycle {
    ignore_changes = [ami]
  }

  count = var.worker_instance_count
}
