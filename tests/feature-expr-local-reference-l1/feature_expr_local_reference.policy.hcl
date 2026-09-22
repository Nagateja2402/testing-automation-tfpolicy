# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_local_reference
# Covers : local.<name> reads policy-scoped locals
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "feature_expr_local_reference" {
  locals {
    bucket = core::try(attrs.bucket, "")
  }
  enforce {
    condition    = local.bucket != ""
    info_message = "local.bucket = ${local.bucket}"
  }
}
