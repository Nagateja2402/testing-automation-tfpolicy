# Copyright (c) HashiCorp, Inc.
# EC-OP-001: Duplicate operations values — ["create", "create"] — validation behavior.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "duplicate_create_operations" {
  operations = ["create", "create"]

  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "Environment tag required"
  }
}
