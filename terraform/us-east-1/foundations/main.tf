module "network" {
  source = "../../modules/network"

  network_identifier = "east"
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "compute" {
  source = "../../modules/compute"

  cluster_identifier              = "east-1"
  cloud_init_files_path           = local.cloud_init_files_path
  cluster_ingress_security_groups = [module.ingress.load_balancer_security_group_id]
  cluster_subnet_ids              = toset(module.network.private_subnet_ids)
  vpc_id                          = module.network.vpc_id

  coordinator_instance_profile = "cluster-coordinator"
  coordinator_instance_type    = "t2.small"

  worker_instance_profile = "cluster-worker"
  worker_instance_type    = "t3.medium"

  depends_on = [module.network]
}

module "ingress" {
  source = "../../modules/ingress"

  cluster_identifier       = "east-1"
  ingress_safe_list        = [local.my_local_cidr]
  load_balancer_subnet_ids = toset(module.network.public_subnet_ids)
  route53_public_zone_id   = data.aws_route53_zone.public.zone_id
  vpc_id                   = module.network.vpc_id
}

resource "aws_lb_listener_rule" "consul" {
  listener_arn = module.ingress.load_balancer_listener_arn["consul"]
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = module.compute.consul_target_group_arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_listener_rule" "nomad" {
  listener_arn = module.ingress.load_balancer_listener_arn["nomad"]
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = module.compute.nomad_target_group_arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
