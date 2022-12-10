variable "group_name" {
  type = string
  description = "Name of the group"
}

variable "group_policy_arns" {
  type = list(string)
  description = "A list of the arns of policies to attach to the group"
}