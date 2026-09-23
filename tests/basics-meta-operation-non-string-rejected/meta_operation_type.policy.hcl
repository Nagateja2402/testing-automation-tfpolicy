# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Regression for terraform-policy-cli #93 (0.2.0): `tfpolicy test` no longer
# panics when a test file sets `meta.operation` to a non-string value. The
# offending resource and the actual type received are now reported as a
# diagnostic during pre-flight validation, instead of crashing.
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
