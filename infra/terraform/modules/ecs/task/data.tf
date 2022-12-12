data "aws_iam_policy_document" "task_policy" {
  dynamic "statement" {
    for_each = var.iam_policy_statements
    content {
      sid       = statement.key
      actions   = statement.value.actions
      effect    = statement.value.effect
      resources = statement.value.resources

      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}