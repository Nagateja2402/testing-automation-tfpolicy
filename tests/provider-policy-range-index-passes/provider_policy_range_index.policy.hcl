# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

provider_policy "aws" "region_index" {
  locals {
    allowed_regions = ["us-east-1", "us-west-2"]
    matches         = [for i in core::range(core::length(local.allowed_regions)) : i if local.allowed_regions[i] == core::try(attrs.region, "")]
    idx             = core::length(local.matches) > 0 ? local.matches[0] : -1
  }
  enforce {
    condition     = local.idx >= 0
    error_message = "Provider region '${core::try(attrs.region, "")}' index is ${local.idx}; not in allowed list: ${core::join(", ", local.allowed_regions)}"
  }
}
