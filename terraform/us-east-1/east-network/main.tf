module "network" {
  source = "../../modules/network"

  network_identifier = "east"
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}
