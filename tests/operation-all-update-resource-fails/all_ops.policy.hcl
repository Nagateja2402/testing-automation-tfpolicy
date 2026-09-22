# Copyright (c) HashiCorp, Inc.
# Policy covering all three operations: ResourceName tag always required.
# create/delete cannot share one resource_policy block (incompatible
# operations), so this is split into a create+update block and a delete block.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "all_ops_require_resource_name_tag" {
  operations = ["create", "update"]

  enforce {
    condition     = core::try(attrs.tags.ResourceName, "") != ""
    error_message = "All lifecycle operations must have the ResourceName tag set"
  }
}

resource_policy "aws_s3_bucket" "delete_requires_resource_name_tag" {
  operations = ["delete"]

  enforce {
    condition     = core::try(attrs.tags.ResourceName, "") != ""
    error_message = "All lifecycle operations must have the ResourceName tag set"
  }
}
