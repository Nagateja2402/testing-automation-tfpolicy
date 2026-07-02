# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "must_have_logging_bucket_in_region" {
  locals {
    matching_buckets = core::getresources("aws_s3_bucket", {
      region = attrs.region
      acl    = "private"
    })
  }

  enforce {
    condition     = core::length(local.matching_buckets) > 0
    error_message = "There must be at least one private S3 bucket in the same region"
  }
}
