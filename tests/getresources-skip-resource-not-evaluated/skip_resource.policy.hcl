# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "must_have_logging_partner" {
  locals {
    logging_partners = core::getresources("aws_s3_bucket", {
      bucket = "${attrs.bucket}-logs"
    })
  }

  enforce {
    condition     = core::length(local.logging_partners) > 0
    error_message = "S3 bucket must have a corresponding -logs bucket"
  }
}
