# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Regression for terraform-policy-cli #96 (0.2.0): `tfpolicy validate` checks
# `meta` references against the metadata each policy kind actually receives
# at runtime. A provider_policy only exposes meta.type/name/alias/namespace/
# source/version — a typo'd field ("regio" instead of "region", which isn't
# even a real provider meta field) must fail validation.
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

provider_policy "aws" "typo_meta_field" {
  enforce {
    condition     = meta.regio != ""
    error_message = "region must be set"
  }
}
