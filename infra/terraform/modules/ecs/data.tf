data "aws_iam_policy" "autoscale_role" {
  name = "AmazonEC2ContainerServiceAutoscaleRole"
}

data "aws_iam_policy" "container_service_role" {
  name = "AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy" "container_service_role_ec2" {
  name = "AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy" "events_role" {
  name = "AmazonEC2ContainerServiceEventsRole"
}

data "aws_iam_policy" "task_execution" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "task_execution_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_region" "current" {}

