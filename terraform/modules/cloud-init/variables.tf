variable "cluster_identifier" {
  type = string
}

variable "machine_role" {
  default = "cluster-worker"
}

variable "coordinator_instance_count" {
  type    = number
  default = 3
}
