# Copyright (c) HashiCorp, Inc.
# EC-GR-001: getresources called inside filter expression.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_vpc" "filter_on_getresources" {
  filter = core::length(core::getresources("aws_flow_log", { vpc_id = attrs.id })) > 0

  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "VPCs with flow logs must have an Environment tag"
  }
}
