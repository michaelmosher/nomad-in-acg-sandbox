variable "network_identifier" {
  type = string
}

variable "availability_zones" {
  type = set(string)
}

variable "vpc_cidr_block" {
  default = "192.168.0.0/24"

  validation {
    condition     = can(cidrsubnet(var.vpc_cidr_block, 4, 5))
    error_message = "This doesn't look like a sufficient cidr range to me."
  }
}
