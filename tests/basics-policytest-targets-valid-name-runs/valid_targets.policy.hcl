# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Positive counterpart to basics-policytest-targets-mismatch-rejected: a
# `targets` entry that correctly names an existing policy file runs normally.
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
