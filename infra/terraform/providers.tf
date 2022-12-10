terraform {
  required_version = "= 1.3.6"

  cloud {
    organization = "bkimbrough"

    workspaces {
      name = "incode-test"
    }
  }

  required_providers {
    aws    = {
      source  = "hashicorp/aws"
      version = "~> 4.45"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      managedBy = "Terraform"
    }
  }
}