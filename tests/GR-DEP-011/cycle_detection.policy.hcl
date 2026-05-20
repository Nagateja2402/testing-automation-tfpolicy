# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "bucket_check" {
  enforce {
    condition     = core::try(attrs.bucket, "") != ""
    error_message = "Bucket name must not be empty"
  }
}
