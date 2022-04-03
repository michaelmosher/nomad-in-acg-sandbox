terraform {
  required_providers {
    aws = {}
  }
}

locals {
  consul_dcs      = toset([for s in var.services : s.node_datacenter])
  consul_services = toset([for s in var.services : s.name])

  consul_service_health_checks = {
    for s in var.services : "${s.node_datacenter}-${s.name}" => coalesce(s.meta.health_check, "/")
  }

  consul_service_vpc_ids = {
    for s in var.services : "${s.node_datacenter}-${s.name}" => s.cts_user_defined_meta.vpc_id
  }

  consul_dc_services = [
    for pair in setproduct(local.consul_dcs, local.consul_services) : {
      dc              = pair[0]
      name            = pair[1]
      lb_listener_arn = data.aws_lb_listener.https[pair[0]].arn
    }
  ]
}


// for each service
resource "aws_lb_listener_rule" "this" {
  for_each = { for dcs in local.consul_dc_services : "${dcs.dc}-${dcs.name}" => dcs }

  listener_arn = each.value.lb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  condition {
    path_pattern {
      values = ["/${each.value.name}*"]
    }
  }
}

// for each service
resource "aws_lb_target_group" "this" {
  for_each = toset([for s in var.services : "${s.node_datacenter}-${s.name}"])

  name     = each.value
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.consul_service_vpc_ids[each.value]

  health_check {
    path = local.consul_service_health_checks[each.value]
  }
}

// for each service instance
resource "aws_lb_target_group_attachment" "this" {
  for_each = var.services

  target_group_arn = aws_lb_target_group.this["${each.value.node_datacenter}-${each.value.name}"].arn
  target_id        = data.aws_instance.worker[each.key].id
  port             = each.value.port
}
