# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_length
# Covers : core::length returns collection length
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "feature_func_core_length" {
  enforce {
    condition    = core::length(["a","b","c"]) == 3
    info_message = "core::length executed"
  }
}
