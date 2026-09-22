# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_vpc" "must_have_all_traffic_flow_log" {
  locals {
    flow_logs = core::getresources("aws_flow_log", {
      vpc_id = attrs.id
    })
  }

  enforce {
    condition     = core::length(local.flow_logs) > 0
    error_message = "All VPCs must have an associated flow log"
  }

  enforce {
    condition     = core::length(local.flow_logs) > 0 ? core::try(local.flow_logs[0].traffic_type, "") == "ALL" : false
    error_message = "VPC flow log must capture ALL traffic, not just REJECT or ACCEPT"
  }
}
