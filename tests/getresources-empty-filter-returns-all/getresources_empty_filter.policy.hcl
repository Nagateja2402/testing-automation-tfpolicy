# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "at_least_one_bucket_exists" {
  locals {
    all_buckets = core::getresources("aws_s3_bucket", {})
  }

  enforce {
    condition     = core::length(local.all_buckets) > 0
    error_message = "At least one S3 bucket must exist in the configuration"
  }
}
