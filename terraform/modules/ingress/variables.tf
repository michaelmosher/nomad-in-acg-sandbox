variable "cluster_identifier" {
  type = string
}

variable "ingress_safe_list" {
  type = list(string)
}

variable "load_balancer_subnet_ids" {
  type = set(string)
}

variable "route53_public_zone_id" {}

variable "vpc_id" {}
