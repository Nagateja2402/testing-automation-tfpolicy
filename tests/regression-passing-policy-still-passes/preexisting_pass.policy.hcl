# Copyright (c) HashiCorp, Inc.
# REG-BIN-001: Pre-existing passing policy must still pass on new binary.
# Uses a simple resource_policy that has always passed.

policy {}

resource_policy "aws_s3_bucket" "require_environment_tag" {
  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "S3 bucket must have an Environment tag"
  }
}
