output "nomad_volume_registration_info" {
  value = <<-EOF
    id = "${local.app_name}-ebs"
    name = "${local.app_name}-ebs"
    type = "csi"
    external_id = "${aws_ebs_volume.this.id}"
    plugin_id = "aws-ebs"

    capability {
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }
  EOF
}
