# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
provider_policy "aws" "region_must_be_allowed" {
  locals {
    allowed_regions = ["us-east-1", "us-west-2", "eu-west-1"]
    is_allowed      = core::contains(local.allowed_regions, core::try(attrs.region, ""))
  }

  enforce {
    condition     = attrs.region != null && local.is_allowed
    error_message = "AWS region must be one of: ${core::join(", ", local.allowed_regions)}"
  }
}
