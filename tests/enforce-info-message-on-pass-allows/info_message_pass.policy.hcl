# Copyright (c) HashiCorp, Inc.
# EC-ENF-002: info_message on passing condition.

policy {}

resource_policy "aws_s3_bucket" "info_message_on_pass" {
  enforce {
    condition    = core::try(attrs.tags.Environment, "") != ""
    info_message = "Environment tag is present — compliant"
  }
}
