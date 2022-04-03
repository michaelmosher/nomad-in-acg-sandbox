output "consul_target_group_arn" {
  value = aws_lb_target_group.consul.arn
}

output "nomad_target_group_arn" {
  value = aws_lb_target_group.nomad.arn
}
