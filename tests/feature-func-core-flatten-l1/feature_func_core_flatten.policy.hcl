# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_flatten
# Covers : core::flatten flattens nested lists
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "feature_func_core_flatten" {
  enforce {
    condition    = core::length(core::flatten([[1,2],[3]])) == 3
    info_message = "core::flatten executed"
  }
}
