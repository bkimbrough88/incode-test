module "vpc" {
  source = "./modules/vpc"

  aws_service_endpoints = {
    "s3"       = "Gateway"
    "dynamodb" = "Gateway"
  }

  cidr_block = "10.0.0.0/16"

  main_private_subnet_cidrs = {
    "us-west-2a" = "10.0.0.0/24"
    "us-west-2b" = "10.0.1.0/24"
    "us-west-2c" = "10.0.2.0/24"
    "us-west-2d" = "10.0.3.0/24"
  }

  main_public_subnet_cidrs = {
    "us-west-2a" = "10.0.4.0/24"
    "us-west-2b" = "10.0.5.0/24"
    "us-west-2c" = "10.0.6.0/24"
    "us-west-2d" = "10.0.7.0/24"
  }
}

## Comment this after first apply to remove default VPC from region
#module "default_vpc" {
#  source = "./modules/default_vpc"
#}