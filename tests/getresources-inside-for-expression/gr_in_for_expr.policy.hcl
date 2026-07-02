# Copyright (c) HashiCorp, Inc.
# EC-GR-005: getresources inside for expression in locals.

policy {}

resource_policy "aws_vpc" "flow_log_traffic_types" {
  locals {
    flow_logs     = core::getresources("aws_flow_log", { vpc_id = attrs.id })
    traffic_types = [for log in local.flow_logs : core::try(log.traffic_type, "UNKNOWN")]
  }

  enforce {
    condition     = core::contains(local.traffic_types, "ALL")
    error_message = "VPC must have a flow log capturing ALL traffic"
  }
}
