output "ingress_fqdn" {
  value = aws_route53_record.ingress.fqdn
}

output "load_balancer_dns" {
  value = aws_lb.main.dns_name
}

output "load_balancer_listener_arn" {
  value = { for k, v in aws_lb_listener.main : k => v.arn }
}
