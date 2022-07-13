terraform {
  required_version = "~> 1.2.4"

  cloud {
    organization = "michael-mosher"

    workspaces {
      name = "nomad-in-acg-sandbox-east-1-foundations"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "cloudinit" {}

locals {
  cloud_lab_dns         = ""
  my_local_cidr         = ""
}
