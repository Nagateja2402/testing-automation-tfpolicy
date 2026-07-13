# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_jsondecode
# Covers : core::jsondecode decodes a JSON string
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_core_jsondecode" {
  enforce {
    condition    = core::jsondecode("{\"a\":1}").a == 1
    info_message = "core::jsondecode executed"
  }
}
