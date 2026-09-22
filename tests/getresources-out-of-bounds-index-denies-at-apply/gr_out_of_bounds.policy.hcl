# Copyright (c) HashiCorp, Inc.
# EC-GR-002: getresources result indexed beyond bounds — core::try prevents panic.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_vpc" "access_beyond_bounds" {
  locals {
    flow_logs = core::getresources("aws_flow_log", { vpc_id = attrs.id })
    # Accessing index 5 on a list that may have 0 or 1 elements.
    # core::try prevents an index-out-of-bounds panic.
    fifth_log = core::try(local.flow_logs[5].traffic_type, "NONE")
  }

  enforce {
    condition     = local.fifth_log == "ALL"
    error_message = "No fifth flow log found with traffic_type=ALL"
  }
}
