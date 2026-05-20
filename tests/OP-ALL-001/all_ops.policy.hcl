# Copyright (c) HashiCorp, Inc.
# Policy covering all three operations: ResourceName tag always required.

policy {}

resource_policy "aws_s3_bucket" "all_ops_require_resource_name_tag" {
  operations = ["create", "update", "delete"]

  enforce {
    condition     = core::try(attrs.tags.ResourceName, "") != ""
    error_message = "All lifecycle operations must have the ResourceName tag set"
  }
}
