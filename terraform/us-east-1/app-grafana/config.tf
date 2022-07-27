terraform {
  required_version = "~> 1.2.4"

  cloud {
    organization = "michael-mosher"

    workspaces {
      name = "nomad-in-acg-sandbox-east-1-app-grafana"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      app_name   = local.app_name
      cluster_id = local.cluster_id
    }
  }
}

locals {
  app_name   = "grafana"
  network_id = "east"
  cluster_id = "east-1"
}
