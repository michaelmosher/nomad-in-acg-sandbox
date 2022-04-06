terraform {
  required_version = "~> 1.1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }
  }

  backend "s3" {
    bucket = ""
    key    = "terraform/us-east-1/app-victoria-metrics.tfstate"
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
