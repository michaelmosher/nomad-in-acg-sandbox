variable "cluster_identifier" {
  type = string
}

variable "cluster_ingress_security_groups" {
  type    = list(string)
  default = []
}

variable "cluster_ingress_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "cluster_subnet_ids" {
  type = set(string)
}

variable "coordinator_instance_count" {
  type    = number
  default = 3
}

variable "coordinator_instance_profile" {
  type    = string
  default = null
}

variable "coordinator_instance_type" {}

variable "coordinator_user_data" {}

variable "vpc_id" {}

variable "worker_instance_count" {
  type    = number
  default = 2
}

variable "worker_instance_profile" {
  type    = string
  default = null
}

variable "worker_instance_type" {}

variable "worker_user_data" {}
