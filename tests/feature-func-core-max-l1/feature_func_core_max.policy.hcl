# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_max
# Covers : core::max returns largest of arguments
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_core_max" {
  enforce {
    condition    = core::max(3, 1, 2) == 3
    info_message = "core::max executed"
  }
}
