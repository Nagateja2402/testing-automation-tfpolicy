# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_metaarg_operations_delete
# Covers : operations = [delete] runs only on delete
# =============================================================================

resource_policy "aws_s3_bucket" "feature_metaarg_operations_delete" {
  operations = ["delete"]
  enforce {
    condition    = true
    info_message = "delete rule reached"
  }
}
