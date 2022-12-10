output "user_passwords" {
  value = [ for user, obj in var.users : {
    user     = user
    password = aws_iam_user_login_profile.login[user].encrypted_password
  } ]
}