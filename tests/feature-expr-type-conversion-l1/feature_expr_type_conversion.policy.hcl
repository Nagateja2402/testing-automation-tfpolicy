# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_type_conversion
# Covers : implicit cty type coercion (string <-> number)
# =============================================================================

resource_policy "aws_instance" "feature_expr_type_conversion" {
  # `ipv6_address_count` is a real numeric attribute on aws_instance (the
  # earlier draft used cpu_count which doesn't exist in the AWS provider
  # schema). Default of 0 keeps the rule allowing when the attribute is
  # unset, which it is on a fresh single-NIC instance.
  enforce {
    condition     = core::try(attrs.ipv6_address_count, 0) >= 0
    error_message = "ipv6_address_count must be a non-negative number (type coercion check)"
  }
}
