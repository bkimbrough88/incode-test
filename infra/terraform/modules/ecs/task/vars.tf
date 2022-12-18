variable "assume_role_policy" {
  type        = string
  description = "The policy JSON for the task's execution role"
}

variable "capacity_provider_name" {
  type        = string
  description = "The name of the capacity provider"
}

variable "cluster_id" {
  type        = string
  description = "The id of the cluster to deploy the task into"
}

variable "container_name" {
  type        = string
  description = "The name of the container"
}

variable "container_image" {
  type        = string
  description = "The image to be used for the container"
}

variable "container_image_tag" {
  type        = string
  description = "The image tag to be used for the container"
}

variable "cpu" {
  type        = string
  description = "The CPU value to request for task"
}

variable "domain_name" {
  type        = string
  description = "The domain name to register the cert with"
  default     = "example.com"
}

variable "deployment_max_percent" {
  type        = number
  description = "The max percentage of the replicas to scale up to while deploying"
  default     = 200
}

variable "execution_role_arn" {
  type        = string
  description = "The ARN for the execution role"
}

variable "iam_policy_statements" {
  type        = map(object({
    actions    = list(string)
    conditions = map(object({
      test     = string
      values   = list(string)
      variable = string
    }))
    effect     = string
    resources  = list(string)
  }))
  description = "A list of statements to add the the task's role"
}

variable "internal" {
  type        = string
  description = "Indicates if the load balancer should be exposed internally or publicly"
}

variable "memory" {
  type        = string
  description = "The memory value to request for task"
}

variable "name" {
  type        = string
  description = "The name of the task to be created"
}

variable "network_mode" {
  type        = string
  description = "The network mode to use for the task"
  default     = "awsvpc"
}

variable "replicas" {
  type        = number
  description = "The number of replicas of the task to deploy"
}

variable "region" {
  type        = string
  description = "The region to be deployed into"
}

variable "subnets" {
  type        = list(string)
  description = "The list of ids of the subnets to deploy into"
}

variable "use_tls" {
  type        = bool
  description = "Indicates if TLS should be used when serving the applications"
}

variable "vpc_id" {
  type        = string
  description = "The id of the VPC to deploy into"
}
