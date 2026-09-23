# Copyright (c) HashiCorp, Inc.
# EC-OP: tfpolicy 0.3.0 rejects a meta-only test case — an explicit
# meta.operation with no attrs/prior_attrs state block. A minimal state
# block matching the declared operation (e.g. prior_attrs = { id = null }
# for a delete) must be declared instead.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "meta_only_rejected" {
  operations = ["delete"]

  enforce {
    condition     = core::try(prior_attrs.tags.Environment, "") != ""
    error_message = "Environment tag required on deleted bucket"
  }
}
