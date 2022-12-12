#############################################
## EC2 Resources
#############################################
resource "aws_launch_template" "template" {
  name_prefix   = "incode-test-ecs"
  image_id      = "ami-094125af156557ca2"  # Amazon Linux 2
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "asg" {
  health_check_type = "EC2"
  max_size = 3
  min_size = 1
  protect_from_scale_in = true  # required by ECS
  vpc_zone_identifier = var.asg_subnets

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

#############################################
## ECR Resources
#############################################
resource "aws_ecr_repository" "repo" {
  name         = "incode-test"
  force_delete = true   # just for easy cleanup of environment

  image_scanning_configuration {
    scan_on_push = true
  }
}

#############################################
## ECS Resources
#############################################
resource "aws_ecs_cluster" "cluster" {
  name = "incode-test"
}

resource "aws_ecs_capacity_provider" "provider" {
  name = "incode-test"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 2
    }
  }
}

module "task" {
  source   = "./task"
  for_each = var.tasks

  assume_role_policy    = data.aws_iam_policy_document.task_execution_assume_role_policy.json
  cluster_id            = aws_ecs_cluster.cluster.id
  container_image       = each.value.container_image
  container_image_tag   = each.value.container_image_tag
  container_name        = each.value.container_name
  cpu                   = each.value.cpu
  domain_name           = each.value.domain_name
  execution_role_arn    = aws_iam_role.task_execution_role.arn
  iam_policy_statements = each.value.task_iam_policy_statements
  image_repo            = aws_ecr_repository.repo.repository_url
  internal              = each.value.internal
  memory                = each.value.memory
  name                  = each.key
  region                = data.aws_region.current.name
  replicas              = each.value.replicas
  subnets               = each.value.subnets
  use_tls               = var.use_tls
  vpc_id                = var.vpc_id
}

#############################################
## IAM Resources
#############################################
resource "aws_iam_role" "task_execution_role" {
  name               = "incode-test-execution"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  policy_arn = data.aws_iam_policy.task_execution.arn
  role       = aws_iam_role.task_execution_role.name
}