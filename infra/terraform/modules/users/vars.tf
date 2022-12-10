variable "groups" {
  type        = map(list(string))
  description = "Map of group names and a list of the policies to apply to the group"
}

variable "users" {
  type        = map(object({
    groups  = list(string)
    pgp_key = optional(string)
  }))
  description = "Map of users names with an object containing the pgp key and a list of groups they belong to"
}