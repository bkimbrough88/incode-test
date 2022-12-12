variable "tasks" {
  type = map(object({
    container_name             = string
    container_image            = string
    container_image_tag        = string
    cpu                        = string
    domain_name                = optional(string)
    deployment_max_percent     = number
    internal                   = bool
    memory                     = string
    replicas                   = number
    subnets                    = list(string)
    task_iam_policy_statements = map(object({
      actions    = list(string)
      conditions = map(object({
        test     = string
        values   = list(string)
        variable = string
      }))
      effect     = string
      resources  = list(string)
    }))
  }))
  description = "A map of tasks to be deployed"
}

variable "asg_subnets" {
  type = list(string)
  description = "A list of subnet IDs that the autoscaling group can deploy into"
}

variable "use_tls" {
  type        = bool
  description = "Indicates if TLS should be used when serving the applications"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to deploy into"
}