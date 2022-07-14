#!/usr/bin/env nomad job run

locals {
  plugin_image = "public.ecr.aws/ebs-csi-driver/aws-ebs-csi-driver"
  plugin_image_tag = "v1.9.0"
}

job "csi-aws-ebs-controller" {
  datacenters = ["east-1"]

  group "containerd" {
    task "driver" {
      driver = "containerd-driver"

      config {
        image = "${local.plugin_image}:${local.plugin_image_tag}"

        args = [
          "controller",
          "--endpoint=unix://run/csi.sock",
          "--logtostderr",
          "--v=5",
        ]

        host_network = true
      }

      csi_plugin {
        id        = "aws-ebs"
        type      = "controller"
        mount_dir = "/run"
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}