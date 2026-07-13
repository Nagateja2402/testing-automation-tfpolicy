# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_contains
# Covers : core::contains tests list membership
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_core_contains" {
  enforce {
    condition    = core::contains(["a","b"], "a")
    info_message = "core::contains executed"
  }
}
