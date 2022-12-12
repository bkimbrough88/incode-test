resource "aws_iam_group_policy_attachment" "attachment" {
  for_each = toset(var.group_policy_arns)

  group      = var.group_name
  policy_arn = each.key

  lifecycle {
    prevent_destroy = true
  }
}