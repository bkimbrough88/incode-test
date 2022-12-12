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

data "aws_region" "current" {}

