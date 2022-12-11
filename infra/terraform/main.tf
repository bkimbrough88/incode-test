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

module "users" {
  source = "./modules/users"

  groups = {
    Admins = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    Viewers = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  }

  users = {
    "brandon.kimbrough" = {
      groups = ["Admins"]
    }
    "carlos" = {
      groups = ["Viewers"]
    }
    "sean" = {
      groups = ["Viewers"]
    }
  }
}

module "ecs" {
  source = "./modules/ecs"
  back_image_name = "incode-test-back"
  back_image_tag = "latest"
  back_task_allow_permissions = [
    "dynamodb:Describe*",
    "dynamodb:Get*",
    "dynamodb:List*",
    "dynamodb:BatchGetItem",
    "dynamodb:BatchWriteItem",
    "dynamodb:ConditionCheckItem",
    "dynamodb:Scan",
    "dynamodb:Query",
    "dynamodb:UpdateItem"
  ]
  front_image_name = "incode-test-front"
  front_image_tag = "latest"
  private_subnets = module.vpc.main_private_subnet_cidrs
  public_subnets = module.vpc.main_public_subnet_cidrs
  use_tls = false
  vpc_cidr = module.vpc.cidr
  vpc_id = module.vpc.id
}