# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
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
