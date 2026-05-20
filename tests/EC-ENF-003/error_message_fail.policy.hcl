# Copyright (c) HashiCorp, Inc.
# EC-ENF-003: error_message on failing condition.

policy {}

resource_policy "aws_s3_bucket" "error_message_on_fail" {
  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "EC-ENF-003: Environment tag is missing — non-compliant"
  }
}
