# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_enforce_single_block
# Covers : exactly one enforce block per rule
# =============================================================================

resource_policy "aws_s3_bucket" "feature_enforce_single_block" {
  enforce {
    condition    = true
    info_message = "single enforce block"
  }
}
