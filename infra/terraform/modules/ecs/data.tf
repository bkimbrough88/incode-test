data "aws_region" "current" {}

data "aws_iam_policy" "task_execution" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "front_task_policy" {
  statement {
    actions = var.front_task_allow_permissions
    effect = "Allow"
  }
  statement {
    actions = var.front_task_deny_permissions
    effect = "Deny"
  }
}

data "aws_iam_policy_document" "back_task_policy" {
  statement {
    actions = var.back_task_allow_permissions
    effect = "Allow"
  }
  statement {
    actions = var.back_task_deny_permissions
    effect = "Deny"
  }
}

data "aws_iam_policy_document" "task_execution_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}
