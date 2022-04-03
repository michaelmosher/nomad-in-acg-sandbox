data "aws_lb" "this" {
  for_each = local.consul_dcs

  name = each.value
}

data "aws_lb_listener" "https" {
  for_each = local.consul_dcs

  load_balancer_arn = data.aws_lb.this[each.value].arn
  port              = 443
}

data "aws_instance" "worker" {
  for_each = var.services

  filter {
    name   = "private-dns-name"
    values = [each.value.node]
  }
}
