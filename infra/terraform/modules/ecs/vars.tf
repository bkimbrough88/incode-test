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

variable "back_image_name" {
  type = string
  description = "The name of the image to deploy for the backend service"
}

variable "back_image_tag" {
  type = string
  description = "The tag of the image to deploy for the backend service"
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

variable "front_image_name" {
  type = string
  description = "The name of the image to deploy for the frontend service"
}

variable "front_image_tag" {
  type = string
  description = "The tag of the image to deploy for the frontend service"
}

variable "private_subnets" {
  type = list(string)
  description = "A list of private subnet CIDRs to use when deploying services"
}

variable "public_subnets" {
  type = list(string)
  description = "A list of public subnet CIDRs to use when deploying services"
}

variable "use_tls" {
  type = bool
  description = "Indicates if TLS should be used when serving the applications"
}

variable "vpc_id" {
  type = string
  description = "The ID of the VPC to deploy into"
}

variable "vpc_cidr" {
  type = string
  description = "The CIDR of the VPC to deploy into"
}