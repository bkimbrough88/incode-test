resource "aws_dynamodb_table" "posts" {
  hash_key = var.hash_key
  name     = var.table_name
  billing_mode = var.billing_mode
  read_capacity = var.provisioned_read_capacity
  write_capacity = var.provisioned_write_capacity

  dynamic "attribute" {
    for_each = var.table_attributes
    content {
      name = attribute.key
      type = attribute.value
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indices
    content {
      name           = global_secondary_index.key
      hash_key       = global_secondary_index.value.hash_key
      projection_type = global_secondary_index.value.projection
    }
  }
}