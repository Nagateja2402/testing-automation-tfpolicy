# Copyright (c) HashiCorp, Inc.
# EC-GR-003: getresources with null filter attribute value.

policy {}

resource_policy "aws_vpc" "filter_with_null_value" {
  locals {
    # attrs.owner_id may be null; using it as a filter value with null.
    flow_logs = core::getresources("aws_flow_log", {
      vpc_id = core::try(attrs.owner_id, null)
    })
  }

  enforce {
    condition     = core::length(local.flow_logs) >= 0
    error_message = "getresources with null filter should return empty list gracefully"
  }
}
