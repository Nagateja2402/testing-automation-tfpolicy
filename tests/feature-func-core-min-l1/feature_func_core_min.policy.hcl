# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_min
# Covers : core::min returns smallest of arguments
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_core_min" {
  enforce {
    condition    = core::min(3, 1, 2) == 1
    info_message = "core::min executed"
  }
}
