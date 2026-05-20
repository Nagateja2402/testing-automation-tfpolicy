# Copyright (c) HashiCorp, Inc.
# REG-BIN-008: Topological order deterministic across runs.
# Multiple resources with cross-references to verify consistent eval order.

policy {}

resource_policy "aws_vpc" "must_have_flow_log" {
  locals {
    flow_logs = core::getresources("aws_flow_log", {
      vpc_id = attrs.id
    })
  }

  enforce {
    condition     = core::length(local.flow_logs) > 0
    error_message = "VPC must have a flow log"
  }
}

resource_policy "aws_flow_log" "must_capture_all_traffic" {
  enforce {
    condition     = core::try(attrs.traffic_type, "") == "ALL"
    error_message = "Flow log must capture ALL traffic"
  }
}
