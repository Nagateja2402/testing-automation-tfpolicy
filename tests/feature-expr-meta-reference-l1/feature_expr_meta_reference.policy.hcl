# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_meta_reference
# Covers : meta.<name> reads metadata such as provider type
# =============================================================================

resource_policy "aws_s3_bucket" "feature_expr_meta_reference" {
  enforce {
    condition    = core::try(meta.provider_type, "") == "aws"
    info_message = "meta.provider_type = ${meta.provider_type}"
  }
}
