# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_keys
# Covers : core::keys returns map keys
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_core_keys" {
  enforce {
    condition    = core::contains(core::keys({ a = 1, b = 2 }), "a")
    info_message = "core::keys executed"
  }
}
