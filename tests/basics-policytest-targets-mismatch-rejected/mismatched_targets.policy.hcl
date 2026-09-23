# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Regression for terraform-policy-cli #96 (0.2.0): a `targets` entry in a
# .policytest.hcl file that matches no policy is reported as an error instead
# of being silently skipped (which previously ran nothing and reported
# success).
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "bucket_name_required" {
  enforcement_level = "advisory"

  enforce {
    condition     = core::try(attrs.bucket, "") != ""
    error_message = "bucket name required"
  }
}
