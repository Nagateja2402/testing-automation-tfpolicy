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
  test_string = "validation"
}

resource_policy "aws_cloudtrail" "trail_local_msg" {
  locals {
    validation_enabled = core::try(attrs.enable_log_file_validation, false)
    greeting           = "${local.test_string}-required"
  }
  enforce {
    condition     = local.validation_enabled
    error_message = "CloudTrail ${local.greeting}: enable_log_file_validation must be true"
  }
}
