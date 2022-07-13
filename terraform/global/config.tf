terraform {
  required_version = "~> 1.2.4"

  cloud {
    organization = "michael-mosher"

    workspaces {
      name = "nomad-in-acg-sandbox-global"
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
