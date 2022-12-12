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
    Admins  = [data.aws_iam_policy.admin.arn]
    Viewers = [data.aws_iam_policy.viewer.arn]
  }

  users = {
    "brandon.kimbrough" = ["Admins"]
    "carlos"            = ["Viewers"]
    "sean"              = ["Viewers"]
  }
}

module "ecs" {
  source = "./modules/ecs"
  depends_on = [module.vpc, module.dynamodb]

  asg_subnets = module.vpc.main_private_subnet_ids
  use_tls = false
  vpc_id  = module.vpc.id

  tasks = {
    "incode-test-back" : {
      container_name         = "back"
      container_image        = "incode-test-back"
      container_image_tag    = "0.0.1"
      cpu                    = "128"
      deployment_max_percent = 200
      internal               = true
      memory                 = "256"
      replicas               = 2
      subnets                = module.vpc.main_private_subnet_ids

      task_iam_policy_statements = {
        dynamo = {
          actions   = [
            "dynamodb:Describe*",
            "dynamodb:Get*",
            "dynamodb:List*",
            "dynamodb:BatchGetItem",
            "dynamodb:BatchWriteItem",
            "dynamodb:ConditionCheckItem",
            "dynamodb:Scan",
            "dynamodb:Query",
            "dynamodb:UpdateItem",
          ]
          conditions = {}
          effect    = "Allow"
          resources = [
            module.dynamodb.table_arn,
            "${module.dynamodb.table_arn}/*"
          ]
        }
        logs = {
          actions   = [
            "logs:Describe*",
            "logs:Get*",
            "logs:List*",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
          ]
          conditions = {}
          effect    = "Allow"
          resources = [
            "*"
          ]
        }
      }
    }
    "incode-test-front" : {
      container_name         = "front"
      container_image        = "incode-test-front"
      container_image_tag    = "0.0.1"
      cpu                    = "128"
      deployment_max_percent = 200
      internal               = true
      memory                 = "256"
      replicas               = 2
      subnets                = module.vpc.main_private_subnet_ids

      task_iam_policy_statements = {
        logs = {
          actions   = [
            "logs:Describe*",
            "logs:Get*",
            "logs:List*",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
          ]
          conditions = {}
          effect    = "Allow"
          resources = [
            "*"
          ]
        }
      }
    }
  }
}

module "dynamodb" {
  source                   = "./modules/dynamodb"
  hash_key                 = "id"
  range_key                = "datePosted"
  table_name               = "posts"
  table_attributes         = {
    id         = "S"
    datePosted = "S"
  }
  global_secondary_indices = {
    "datePosted" = {
      hash_key   = "datePosted"
      projection = "ALL"
    }
  }
}