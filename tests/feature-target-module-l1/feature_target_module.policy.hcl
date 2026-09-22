# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_target_module
# Covers : module_policy targets a module instantiation
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "./modules/*" "feature_target_module" {
  enforce {
    condition    = core::try(meta.source, "") != ""
    info_message = "module target selected"
  }
}
