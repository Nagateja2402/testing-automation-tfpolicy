# Copyright (c) HashiCorp, Inc.
# This policy is valid. The error is in the policytest file:
# prior_attrs used without declaring operations (which would exclude "create").

policy {}

resource_policy "aws_s3_bucket" "immutable_bucket_name" {
  operations = ["update", "delete"]

  enforce {
    condition     = core::try(attrs.bucket, "") == core::try(prior_attrs.bucket, "")
    error_message = "Bucket name cannot change"
  }
}
