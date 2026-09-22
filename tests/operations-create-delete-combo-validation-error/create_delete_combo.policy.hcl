# Copyright (c) HashiCorp, Inc.
# REG-BIN: core v0.5.1 rejects an `operations` list combining create and
# delete in the same resource_policy block; it must be split into two
# separate blocks. This locks in that validation behavior.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "create_delete_combo" {
  operations = ["create", "delete"]

  enforce {
    condition     = core::try(attrs.tags.ResourceName, "") != ""
    error_message = "ResourceName tag required"
  }
}
