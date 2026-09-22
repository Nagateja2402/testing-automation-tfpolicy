# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_for_list
# Covers : for-expression producing a list
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_security_group" "feature_expr_for_list" {
  locals {
    public_ports = [for r in core::try(attrs.ingress, []) : r.from_port if core::contains(core::try(r.cidr_blocks, []), "0.0.0.0/0")]
  }
  enforce {
    condition     = core::length(local.public_ports) == 0
    error_message = "public ingress detected on ports ${core::join(",", [for p in local.public_ports : p])}"
  }
}
