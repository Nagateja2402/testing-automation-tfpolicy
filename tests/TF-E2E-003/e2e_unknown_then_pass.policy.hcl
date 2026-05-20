# Copyright (c) HashiCorp, Inc.
# TF-E2E-003: Full lifecycle — plan with getresources unknown then apply resolves.
# Same as GR-DEP-001 but as end-to-end framing.

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
