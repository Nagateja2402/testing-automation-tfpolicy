# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

locals {
  allowed_region = "us-east-1"
}

provider_policy "aws" "region_local" {
  locals {
    actual   = core::try(attrs.region, "")
    is_match = local.actual == local.allowed_region
  }
  enforce {
    condition     = local.is_match
    error_message = "provider region '${local.actual}' must be '${local.allowed_region}'"
  }
}
