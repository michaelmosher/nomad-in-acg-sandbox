module "network" {
  source = "../../modules/network"

  network_identifier = "east"
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "compute" {
  source = "../../modules/compute"

  cluster_identifier    = "east-1"
  cloud_init_files_path = local.cloud_init_files_path
  cluster_subnet_ids    = toset(module.network.private_subnet_ids)
  vpc_id                = module.network.vpc_id

  controller_instance_profile = "cluster-controller"
  controller_instance_type    = "t2.small"

  worker_instance_profile = "cluster-controller" # fine for now
  worker_instance_type    = "t3.medium"

  depends_on = [module.network]
}
