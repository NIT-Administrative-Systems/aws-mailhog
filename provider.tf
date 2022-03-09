terraform {
  required_version = "~> 1.0"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      app_name    = var.app_name
      environment = var.environment
    }
  }
}