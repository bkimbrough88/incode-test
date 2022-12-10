variable "back_task_allow_permissions" {
  type = list(string)
  description = "A list of permissions that the task(s) are allowed to perform"
  default = []
}

variable "back_task_deny_permissions" {
  type = list(string)
  description = "A list of permissions that the task(s) are NOT allowed to perform"
  default = []
}

variable "front_task_allow_permissions" {
  type = list(string)
  description = "A list of permissions that the task(s) are allowed to perform"
  default = []
}

variable "front_task_deny_permissions" {
  type = list(string)
  description = "A list of permissions that the task(s) are NOT allowed to perform"
  default = []
}