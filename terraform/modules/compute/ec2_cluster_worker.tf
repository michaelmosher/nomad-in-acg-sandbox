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

# resource "aws_spot_fleet_request" "workers" {
#   # for_each = var.controller_subnet_ids

#   allocation_strategy         = "lowestPrice"
#   iam_fleet_role              = "arn:aws:iam::769155720965:role/aws-ec2-spot-fleet-tagging-role"
#   replace_unhealthy_instances = true
#   target_capacity             = 1

#   dynamic "launch_specification" {
#     for_each = [
#       # "t2.nano", "t3.nano",
#       "t2.micro", "t2.small", "t2.medium",
#       "t3.micro", "t3.small", "t3.medium",
#       # "t3a.nano", "t3a.micro", "t3a.small"
#     ]

#     content {
#       instance_type          = launch_specification.value
#       ami                    = data.aws_ami.centos_9.id
#       subnet_id              = [for s in var.controller_subnet_ids : s][0]
#       vpc_security_group_ids = [var.worker_security_group_id]
#       user_data              = data.cloudinit_config.worker_user_data.rendered
#     }
#   }

#   # spot_maintenance_strategies = ??
# }
