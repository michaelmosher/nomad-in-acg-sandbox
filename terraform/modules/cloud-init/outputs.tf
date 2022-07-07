output "rendered_user_data" {
  value = data.cloudinit_config.this.rendered
}
