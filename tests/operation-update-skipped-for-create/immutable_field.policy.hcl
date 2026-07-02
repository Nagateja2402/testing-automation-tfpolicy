# Copyright (c) HashiCorp, Inc.
# Update-only policy; verify it is NOT evaluated on create.

policy {}

resource_policy "aws_s3_bucket" "immutable_bucket_name" {
  operations = ["update"]

  enforce {
    condition     = core::try(attrs.bucket, "") == core::try(prior_attrs.bucket, "")
    error_message = "S3 bucket name is immutable and cannot be changed"
  }
}
