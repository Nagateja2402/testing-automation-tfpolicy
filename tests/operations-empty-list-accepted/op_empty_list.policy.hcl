# Copyright (c) HashiCorp, Inc.
# EC-OP-002: Empty operations list [] — validation error expected.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "empty_operations_list" {
  operations = []

  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "Environment tag required"
  }
}
