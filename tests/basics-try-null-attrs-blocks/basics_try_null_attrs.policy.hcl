# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "prefix_required" {
  locals {
    prefix = core::try(attrs.bucket_prefix, null)
    missing = core::try(attrs.does_not_exist_attr, "")
  }
  enforce {
    condition     = local.prefix != null && local.prefix != "" && local.missing != ""
    error_message = "bucket must set bucket_prefix (attrs absent/null -> core::try default)"
  }
}
