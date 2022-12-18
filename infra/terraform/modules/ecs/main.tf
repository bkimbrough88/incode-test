#############################################
## EC2 Resources
#############################################
locals {
  template_user_data = <<EOT
#!/bin/bash
echo 'ECS_CLUSTER=${aws_ecs_cluster.cluster.name}' >> /etc/ecs/ecs.config
EOT
}
resource "aws_launch_template" "template" {
  name_prefix   = "incode-test-ecs"
  image_id      = "ami-06dafa1b661caec7e"  # Amazon Linux 2 ECS
  instance_type = var.instance_type
  user_data     = base64encode(local.template_user_data)
  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_profile.arn
  }
}

resource "aws_autoscaling_group" "asg" {
  health_check_type   = "EC2"
  max_size            = var.asg_max_instance_count
  min_size            = var.asg_min_instance_count
  vpc_zone_identifier = var.asg_subnets

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
  service_linked_role_arn = "arn:aws:iam::075957496962:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
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

resource "aws_ecs_cluster_capacity_providers" "providers" {
  capacity_providers = [aws_ecs_capacity_provider.provider.name]
  cluster_name       = aws_ecs_cluster.cluster.name

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.provider.name
  }
}

module "task" {
  source   = "./task"
  for_each = var.tasks

  assume_role_policy     = data.aws_iam_policy_document.task_execution_assume_role_policy.json
  capacity_provider_name = aws_ecs_capacity_provider.provider.name
  cluster_id             = aws_ecs_cluster.cluster.id
  container_image        = each.value.container_image
  container_image_tag    = each.value.container_image_tag
  container_name         = each.value.container_name
  cpu                    = each.value.cpu
  domain_name            = each.value.domain_name
  execution_role_arn     = aws_iam_role.task_execution_role.arn
  iam_policy_statements  = each.value.task_iam_policy_statements
  internal               = each.value.internal
  memory                 = each.value.memory
  name                   = each.key
  region                 = data.aws_region.current.name
  replicas               = each.value.replicas
  subnets                = each.value.subnets
  use_tls                = var.use_tls
  vpc_id                 = var.vpc_id
}

#############################################
## IAM Resources
#############################################
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ecs"
  role = aws_iam_role.ec2_profile.name
}

resource "aws_iam_role" "ec2_profile" {
  name               = "ecs"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_profile" {
  policy_arn = data.aws_iam_policy.container_service_role_ec2.arn
  role       = aws_iam_role.ec2_profile.name
}

resource "aws_iam_role" "task_execution_role" {
  name               = "incode-test-execution"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "autoscale" {
  policy_arn = data.aws_iam_policy.autoscale_role.arn
  role       = aws_iam_role.task_execution_role.name
}

resource "aws_iam_role_policy_attachment" "container_service" {
  policy_arn = data.aws_iam_policy.container_service_role.arn
  role       = aws_iam_role.task_execution_role.name
}

resource "aws_iam_role_policy_attachment" "container_service_ec2" {
  policy_arn = data.aws_iam_policy.container_service_role_ec2.arn
  role       = aws_iam_role.task_execution_role.name
}

resource "aws_iam_role_policy_attachment" "events" {
  policy_arn = data.aws_iam_policy.events_role.arn
  role       = aws_iam_role.task_execution_role.name
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  policy_arn = data.aws_iam_policy.task_execution.arn
  role       = aws_iam_role.task_execution_role.name
}