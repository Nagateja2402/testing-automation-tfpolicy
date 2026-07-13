# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_target_resource
# Covers : resource_policy "<type>" "<name>" targets a resource block
# =============================================================================

resource_policy "aws_s3_bucket" "feature_target_resource" {
  enforce {
    condition    = true
    info_message = "resource target selected"
  }
}
