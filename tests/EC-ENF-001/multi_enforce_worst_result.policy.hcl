# Copyright (c) HashiCorp, Inc.
# EC-ENF-001: Multiple enforce blocks — first fails second passes.
# Worst-result (deny) should propagate.

policy {}

resource_policy "aws_s3_bucket" "multiple_enforce_worst_result" {
  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "First enforce: Environment tag required"
  }

  enforce {
    condition     = core::try(attrs.bucket, "") != ""
    error_message = "Second enforce: bucket name required"
  }
}
