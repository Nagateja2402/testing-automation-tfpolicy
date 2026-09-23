# Copyright (c) HashiCorp, Inc.
# OP-ALL: end-to-end coverage for the create/update + delete split that
# core v0.5.1 now requires (a resource_policy's `operations` list can no
# longer combine `create` and `delete`). Exercises the split at the real
# Terraform plan/apply level, not just tfpolicy test mocks.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "create_update_require_resource_name_tag" {
  operations = ["create", "update"]

  enforce {
    condition     = core::try(attrs.tags.ResourceName, "") != ""
    error_message = "create/update: ResourceName tag is required"
  }
}

resource_policy "aws_s3_bucket" "delete_require_resource_name_tag" {
  operations = ["delete"]

  enforce {
    condition     = core::try(prior_attrs.tags.ResourceName, "") != ""
    error_message = "delete: ResourceName tag is required"
  }
}
