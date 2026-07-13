# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_jsonencode
# Covers : core::jsonencode encodes a value as JSON
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_core_jsonencode" {
  enforce {
    condition    = core::jsonencode({ a = 1 }) == "{\"a\":1}"
    info_message = "core::jsonencode executed"
  }
}
