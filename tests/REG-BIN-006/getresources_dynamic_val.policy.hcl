# Copyright (c) HashiCorp, Inc.
# REG-BIN-006: getresources with DynamicVal during validate — no panic.
# Exercises the fix that prevents panics when attrs contain DynamicVal.

policy {}

resource_policy "aws_vpc" "must_have_flow_log" {
  locals {
    flow_logs = core::getresources("aws_flow_log", {
      vpc_id = attrs.id
    })
  }

  enforce {
    condition     = core::length(local.flow_logs) > 0
    error_message = "VPC must have an associated flow log"
  }
}
