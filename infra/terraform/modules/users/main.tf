resource "aws_iam_group" "group" {
  for_each = var.groups

  name = each.key

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_user" "user" {
  for_each = var.users

  name = each.key

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_user_group_membership" "member" {
  for_each = var.users

  groups = each.value
  user   = aws_iam_user.user[each.key].name

  lifecycle {
    prevent_destroy = true
  }
}

module "group_attachments" {
  source   = "./group_attachments"
  for_each = var.groups

  group_name        = aws_iam_group.group[each.key].name
  group_policy_arns = each.value
}