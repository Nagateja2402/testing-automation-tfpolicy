# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_cloudtrail" "ct_bucket_logging" {
  locals {
    ct_bucket = core::getresources("aws_s3_bucket_logging", {
      bucket = attrs.s3_bucket_name
    })
  }
  enforce {
    condition     = core::length(local.ct_bucket) > 0
    error_message = "cross-file getresources found no logging for CloudTrail bucket"
  }
}
