terraform {
  required_version = "~> 1.2.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }
  }

  backend "s3" {
    bucket = ""
    key    = "terraform/global.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}
