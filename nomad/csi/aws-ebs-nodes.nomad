#!/usr/bin/env nomad job run

locals {
  plugin_image = "public.ecr.aws/ebs-csi-driver/aws-ebs-csi-driver"
  plugin_image_tag = "v1.9.0"
}

job "csi-aws-ebs-nodes" {
  datacenters = ["east-1"]
  type = "system"

  group "containerd" {
    task "driver" {
      driver = "containerd-driver"

      config {
        image = "${local.plugin_image}:${local.plugin_image_tag}"

        args = [
          "node",
          "--endpoint=unix://run/csi.sock",
          "--logtostderr",
          "--v=5",
        ]

        host_network = true
        privileged   = true
      }

      csi_plugin {
        id = "aws-ebs"
        type = "node"
        mount_dir = "/run"
      }

      resources {
        cpu    = 500
        memory = 256 # MB
      }
    }
  }
}