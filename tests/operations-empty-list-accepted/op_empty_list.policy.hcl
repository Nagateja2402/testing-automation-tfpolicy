# Copyright (c) HashiCorp, Inc.
# EC-OP-002: Empty operations list [] — validation error expected.

policy {}

resource_policy "aws_s3_bucket" "empty_operations_list" {
  operations = []

  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "Environment tag required"
  }
}
