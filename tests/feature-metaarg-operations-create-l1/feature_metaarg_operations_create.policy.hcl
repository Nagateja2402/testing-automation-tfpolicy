# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_metaarg_operations_create
# Covers : operations = [create] runs only on create
# =============================================================================

resource_policy "aws_s3_bucket" "feature_metaarg_operations_create" {
  operations = ["create"]
  enforce {
    condition    = true
    info_message = "create-only rule"
  }
}
