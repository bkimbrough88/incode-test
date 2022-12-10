resource "aws_iam_group" "group" {
  for_each = var.groups

  name = each.key
}

resource "aws_iam_user" "user" {
  for_each = var.users

  name = each.key
}

resource "aws_iam_user_login_profile" "login" {
  for_each = var.users

  pgp_key = each.value.pgp_key
  user    = aws_iam_user.user[each.key].name
  password_reset_required = true
}

resource "aws_iam_user_group_membership" "member" {
  for_each = var.users

  groups = each.value.groups
  user   = aws_iam_user.user[each.key].name
}

module "group_attachments" {
  source   = "./group_attachments"
  for_each = var.groups

  group_name        = aws_iam_group.group[each.key].name
  group_policy_arns = each.value
}