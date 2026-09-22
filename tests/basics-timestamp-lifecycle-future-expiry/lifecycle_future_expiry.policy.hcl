# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket_lifecycle_configuration" "expiry_in_future" {
  locals {
    current_time        = core::timestamp()
    rule                = core::try(attrs.rule[0], {})
    expiration_date     = core::try(local.rule.expiration[0].date, "")
    has_expiration_date = local.expiration_date != ""
    expiration_time     = local.has_expiration_date ? "${local.expiration_date}T00:00:00Z" : "0000-01-01T00:00:00Z"
    is_future_date      = core::timecmp(local.expiration_time, local.current_time) > 0
  }

  enforce {
    condition     = (!local.has_expiration_date || local.is_future_date)
    error_message = "S3 lifecycle expiration date '${local.expiration_time}' must be in the future"
  }
}
