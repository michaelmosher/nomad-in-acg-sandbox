terraform {
  required_version = "~> 1.1.7"

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

  backend "s3" {
    bucket = ""
    key    = "terraform/us-east-1/foundations.tfstate"
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
