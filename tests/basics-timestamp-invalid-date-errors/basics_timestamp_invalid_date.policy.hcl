# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_ssm_parameter" "expiry_in_future" {
  locals {
    now = core::timestamp()
  }
  enforce {
    condition     = core::timecmp(attrs.value, local.now) > 0
    error_message = "expiration '${attrs.value}' must be in the future (now ${local.now})"
  }
}
