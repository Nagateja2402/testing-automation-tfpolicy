# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_enforce_single_block
# Covers : exactly one enforce block per rule
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "feature_enforce_single_block" {
  enforce {
    condition    = true
    info_message = "single enforce block"
  }
}
