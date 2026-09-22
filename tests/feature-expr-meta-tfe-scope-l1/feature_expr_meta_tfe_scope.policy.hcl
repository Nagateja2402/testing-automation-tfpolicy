# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_meta_tfe_scope
# Covers : meta.tfe_stack / meta.tfe_workspace references now validate and
#          test locally (previously rejected by policy validation).
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "feature_expr_meta_tfe_scope" {
  enforce {
    condition    = core::try(meta.tfe_workspace, "") != "" || core::try(meta.tfe_stack, "") != ""
    info_message = "workspace=${core::try(meta.tfe_workspace, "<unset>")} stack=${core::try(meta.tfe_stack, "<unset>")}"
  }
}
