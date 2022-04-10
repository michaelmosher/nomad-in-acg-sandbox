#!/usr/bin/env nomad job run

locals {
  plugin_image = "amazon/aws-efs-csi-driver"
  plugin_image_tag = "v1.3.6"
}

job "csi-aws-efs-nodes" {
  datacenters = ["east-1"]
  type = "system"

  group "containerd" {
    task "driver" {
      driver = "containerd-driver"

      config {
        image = "${local.plugin_image}:${local.plugin_image_tag}"

        args = [
          "--endpoint=unix://run/csi.sock",
          "--logtostderr",
          "--v=5",
        ]

        host_network = true
        privileged = true
      }

      csi_plugin {
        id = "aws-efs"
        type = "node"
        mount_dir = "/run"
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }
    }
  }
}