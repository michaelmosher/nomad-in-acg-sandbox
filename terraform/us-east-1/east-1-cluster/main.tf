module "cloud_init_coordinator" {
  source = "../../modules/cloud-init"

  cluster_identifier = "east-1"
  machine_role       = "cluster-coordinator"
}

module "cloud_init_worker" {
  source = "../../modules/cloud-init"


  cluster_identifier = "east-1"
  machine_role       = "cluster-worker"
}

module "compute" {
  source = "../../modules/compute"

  cluster_identifier              = "east-1"
  cluster_ingress_security_groups = [module.ingress.load_balancer_security_group_id]
  cluster_subnet_ids              = toset(data.aws_subnets.private.ids)
  vpc_id                          = data.aws_vpc.main.id

  coordinator_instance_profile = "cluster-coordinator"
  coordinator_instance_type    = "t4g.small"
  coordinator_user_data        = module.cloud_init_coordinator.rendered_user_data

  worker_instance_profile = "cluster-worker"
  worker_instance_type    = "t4g.medium"
  worker_user_data        = module.cloud_init_worker.rendered_user_data
}

module "ingress" {
  source = "../../modules/ingress"

  cluster_identifier       = "east-1"
  ingress_safe_list        = [local.my_local_cidr]
  load_balancer_subnet_ids = toset(data.aws_subnets.public.ids)
  route53_public_zone_id   = data.aws_route53_zone.public.zone_id
  vpc_id                   = data.aws_vpc.main.id
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
