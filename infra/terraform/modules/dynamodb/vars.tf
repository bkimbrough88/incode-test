variable "billing_mode" {
  type = string
  description = "The billing mode for the table, must be PROVISIONED or PAY_PER_REQUEST"
  default = "PAY_PER_REQUEST"
}

variable "hash_key" {
  type = string
  description = "The attribute to hash as the primary key"
}

variable "global_secondary_indices" {
  type = map(object({
    hash_key = string
    projection = string
  }))
  description = "A map of secondary indices with their hash keys and projection values"
  default = {}
}

variable "range_key" {
  type = string
  description = "The attribute to use as a range key for sorting"
  default = null
}

variable "provisioned_read_capacity" {
  type = number
  description = "The number of read capacity units to provision"
  default = null
}

variable "provisioned_write_capacity" {
  type = number
  description = "The number of write capacity units to provision"
  default = null
}

variable "table_name" {
  type = string
  description = "The name of the table to create"
}

variable "table_attributes" {
  type = map(string)
  description = "A map of attributes and their types. At least one attribute must be defined and match the hash_attribute name"
}
