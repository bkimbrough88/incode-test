data "aws_iam_policy" "admin" {
  name = "AdministratorAccess"
}

data "aws_iam_policy" "viewer" {
  name = "ReadOnlyAccess"
}