# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_local_global_scope
# Covers : file-scope locals shared across rules in same file
# =============================================================================

locals {
  shared_prefix = "shared-"
}

resource_policy "aws_s3_bucket" "rule_a" {
  enforcement_level = "advisory"
  enforce {
    condition    = core::length(core::regexall("^${local.shared_prefix}", core::try(attrs.bucket, ""))) > 0
    error_message = "bucket must start with ${local.shared_prefix}"
  }
}
