terraform {
  required_version = "~> 1.2.4"

  cloud {
    organization = "michael-mosher"

    workspaces {
      name = "nomad-in-acg-sandbox-east-1-app-victoria-metrics"
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
}

locals {
  app_name   = "victoria-metrics"
  network_id = "east"
  cluster_id = "east-1"
}
