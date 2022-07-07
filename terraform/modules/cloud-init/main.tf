data "cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  dynamic "part" {
    for_each = fileset("${path.module}/${var.machine_role}/", "*.yml")

    content {
      content_type = "text/jinja2"
      content      = file("${path.module}/${var.machine_role}/${part.value}")
      filename     = part.value
    }
  }

  dynamic "part" {
    for_each = var.machine_role == "cluster-coordinator" ? [1] : []

    content {
      content_type = "text/cloud-config"
      filename     = "configure_consul_server.yml"

      content = templatefile(
        "${path.module}/templates/configure_consul_server.tftpl",
        {
          datacenter       = var.cluster_identifier,
          bootstrap_expect = var.coordinator_instance_count,
        }
      )
    }
  }

  dynamic "part" {
    for_each = var.machine_role == "cluster-coordinator" ? [1] : []

    content {
      content_type = "text/cloud-config"
      filename     = "configure_nomad_server.yml"

      content = templatefile(
        "${path.module}/templates/configure_nomad_server.tftpl",
        {
          datacenter       = var.cluster_identifier,
          bootstrap_expect = var.coordinator_instance_count,
        }
      )
    }
  }

  dynamic "part" {
    for_each = var.machine_role == "cluster-worker" ? [1] : []

    content {
      content_type = "text/cloud-config"
      filename     = "configure_consul_agent.yml"

      content = templatefile(
        "${path.module}/templates/configure_consul_agent.tftpl",
        {
          datacenter = var.cluster_identifier,
        }
      )
    }
  }

  dynamic "part" {
    for_each = var.machine_role == "cluster-worker" ? [1] : []

    content {
      content_type = "text/cloud-config"
      filename     = "configure_nomad_agent.yml"

      content = templatefile(
        "${path.module}/templates/configure_nomad_agent.tftpl",
        {
          datacenter = var.cluster_identifier,
        }
      )
    }
  }
}
