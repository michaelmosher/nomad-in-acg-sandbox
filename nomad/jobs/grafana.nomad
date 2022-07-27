#!/usr/bin/env nomad job run

locals {
  plugin_image = "grafana/grafana-oss"
  plugin_image_tag = "9.0.2"
  volume_mount_point = "${NOMAD_TASK_DIR}/ebs/"
}

job "grafana" {
  datacenters = ["east-1"]
  type = "service"

  constraint {
    attribute = "${attr.platform.aws.placement.availability-zone}"
    value     = "us-east-1a"
  }

  group "server" {
    count = 1

    volume "storage" {
      type      = "csi"
      source    = "grafana-ebs"

      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
      read_only = false
    }

    network {
      port "main" {}
    }

    service {
      port = "main"

      meta {
          health_check = "/${NOMAD_JOB_NAME}-${NOMAD_GROUP_NAME}/api/health"
      }

      check {
          type     = "http"
          path     = "/${NOMAD_JOB_NAME}-${NOMAD_GROUP_NAME}/api/health"
          interval = "30s"
          timeout  = "5s"
      }
    }

    task "main" {
      driver = "docker"
      user   = "root"

      config {
        image = "${local.plugin_image}:${local.plugin_image_tag}"
        ports = ["main"]
      }

      env {
        GF_PATHS_DATA = local.volume_mount_point
        GF_PATHS_PROVISIONING = "/etc/grafana/provisioning"
        GF_SERVER_HTTP_PORT = NOMAD_PORT_main
        GF_SERVER_ROOT_URL = "https://east-1.cmcloudlab583.info/grafana-server"
        GF_SERVER_SERVE_FROM_SUB_PATH = "true"
        GF_SERVER_LOG_MODE = "console"
      }

      volume_mount {
        volume      = "storage"
        destination = local.volume_mount_point
        read_only   = false
      }

      resources {
        cpu    = 500
        memory = 256 # MB
      }
    }
  }
}