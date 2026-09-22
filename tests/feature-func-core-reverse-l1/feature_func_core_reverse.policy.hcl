# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_reverse
# Covers : core::reverse reverses a list
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "feature_func_core_reverse" {
  enforce {
    condition    = core::reverse([1,2,3])[0] == 3
    info_message = "core::reverse executed"
  }
}
