# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_conditional
# Covers : ternary conditional expression
# =============================================================================

resource_policy "aws_s3_bucket" "feature_expr_conditional" {
  locals {
    region = core::try(attrs.region, "us-east-1")
    is_us  = local.region == "us-east-1" ? true : false
  }
  enforce {
    condition     = local.is_us
    error_message = "only us-east-1 allowed"
  }
}
