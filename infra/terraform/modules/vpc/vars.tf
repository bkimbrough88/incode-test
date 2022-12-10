variable "aws_service_endpoints" {
  type        = map(string)
  description = "Map of AWS services to create VPC endpoints for with the type of endpoint as the value"
  default     = {}
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

## Private CIDRs
variable "additional_private_subnet_cidrs" {
  type        = map(object({
    name = string
    cidr = string
  }))
  description = "A map of availability zone to cidr range for additional private subnets"
  default     = {}
}

variable "main_private_subnet_cidrs" {
  type        = map(string)
  description = "A map of availability zone to cidr range for main private subnets"
}

## Public CIDRs
variable "additional_public_subnet_cidrs" {
  type        = map(object({
    name = string
    cidr = string
  }))
  description = "A map of availability zone to cidr range for additional private subnets"
  default     = {}
}

variable "main_public_subnet_cidrs" {
  type        = map(string)
  description = "A map of availability zone to cidr range for main public subnets"
}