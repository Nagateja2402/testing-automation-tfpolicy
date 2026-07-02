# Copyright (c) HashiCorp, Inc.
# EC-GR-004: getresources with wrong type for filter value.
# Filter value is a number instead of a string — type mismatch behavior.

policy {}

resource_policy "aws_vpc" "filter_wrong_type" {
  locals {
    # vpc_id is a string, but we pass a number — tests type coercion / error handling.
    flow_logs = core::getresources("aws_flow_log", {
      vpc_id = 12345
    })
  }

  enforce {
    condition     = core::length(local.flow_logs) >= 0
    error_message = "getresources with wrong filter type should not panic"
  }
}
