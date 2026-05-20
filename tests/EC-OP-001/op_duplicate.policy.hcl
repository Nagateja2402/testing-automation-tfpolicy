# Copyright (c) HashiCorp, Inc.
# EC-OP-001: Duplicate operations values — ["create", "create"] — validation behavior.

policy {}

resource_policy "aws_s3_bucket" "duplicate_create_operations" {
  operations = ["create", "create"]

  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "Environment tag required"
  }
}
