variable "groups" {
  type        = map(list(string))
  description = "Map of group names and a list of the policies to apply to the group"
}

variable "users" {
  type        = map(list(string))
  description = "Map of users names with a list of groups they belong to"
}