output "nomad_volume_registration_info" {
  value = <<-EOF
    id = "${local.app_name}-efs"
    name = "${local.app_name}-efs"
    type = "csi"
    external_id = "${aws_efs_file_system.this.id}"
    plugin_id = "aws-efs"

    capability {
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
  EOF
}
