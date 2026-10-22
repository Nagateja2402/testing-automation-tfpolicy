# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "local_allowed_tiers" {
  operations = ["create"]
  locals {
    allowed_tiers = ["gold", "silver"]
    tier          = core::try(attrs.tags["tier"], "none")
  }
  enforce {
    condition     = core::contains(local.allowed_tiers, local.tier)
    error_message = "LOCALCHK: tier '${local.tier}' not in allowed list ${core::length(local.allowed_tiers)} entries"
  }
}
