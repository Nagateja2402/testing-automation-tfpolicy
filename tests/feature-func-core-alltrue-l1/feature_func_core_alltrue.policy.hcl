# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_alltrue
# Covers : core::alltrue returns true only when every element is true
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "feature_func_core_alltrue" {
  locals {
    checks = [
      core::try(attrs.bucket, "") != "",
      core::try(attrs.tags.Environment, "") != "",
    ]
  }
  enforce {
    condition     = core::alltrue(local.checks)
    error_message = "all checks must pass: bucket set and Environment tag set"
  }
}
