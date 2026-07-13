# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_result_allow
# Covers : default Allow when condition true
# =============================================================================

resource_policy "aws_s3_bucket" "feature_result_allow" {
  enforce {
    condition    = true
    info_message = "allow outcome"
  }
}
