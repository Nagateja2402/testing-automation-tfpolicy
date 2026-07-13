# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_attrs_reference
# Covers : attrs.<name> reads a resource attribute
# =============================================================================

resource_policy "aws_s3_bucket" "feature_expr_attrs_reference" {
  enforce {
    condition    = core::try(attrs.bucket, "") != ""
    info_message = "attrs.bucket = ${core::try(attrs.bucket, "")}"
  }
}
