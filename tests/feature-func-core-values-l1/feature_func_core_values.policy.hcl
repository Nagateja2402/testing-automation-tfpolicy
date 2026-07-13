# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_values
# Covers : core::values returns map values
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_core_values" {
  enforce {
    condition    = core::contains(core::values({ a = 1, b = 2 }), 1)
    info_message = "core::values executed"
  }
}
