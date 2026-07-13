# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_splat
# Covers : splat expression extracts a field across a list
# =============================================================================

resource_policy "aws_security_group" "feature_expr_splat" {
  locals {
    ports = core::try(attrs.ingress[*].from_port, [])
  }
  enforce {
    condition     = core::length(local.ports) > 0
    error_message = "ingress rules must declare from_port"
  }
}
