module "network" {
  source = "../../modules/network"

  network_identifier = "east"
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}

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
  cluster_subnet_ids              = toset(module.network.private_subnet_ids)
  vpc_id                          = module.network.vpc_id

  coordinator_instance_profile = "cluster-coordinator"
  coordinator_instance_type    = "t2.small"
  coordinator_user_data        = module.cloud_init_coordinator.rendered_user_data

  worker_instance_profile = "cluster-worker"
  worker_instance_type    = "t3.medium"
  worker_user_data        = module.cloud_init_worker.rendered_user_data

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
