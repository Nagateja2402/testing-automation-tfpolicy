# Copyright (c) HashiCorp, Inc.

policy {}

locals {
  test_string = "hello, world!"
}

resource_policy "aws_cloudtrail" "log_validation_with_locals" {
  locals {
    greeting_message    = local.test_string
    validation_required = true
  }

  enforce {
    condition     = core::try(attrs.enable_log_file_validation, false) && local.validation_required && local.greeting_message == "hello, world!"
    error_message = "CloudTrail log file validation must be enabled"
  }
}
