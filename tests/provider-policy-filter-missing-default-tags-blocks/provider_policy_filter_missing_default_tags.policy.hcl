# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

provider_policy "aws" "region_filter_needs_tags" {
  filter = attrs.region == "us-east-1"
  enforce {
    condition     = core::length(core::try(attrs.default_tags, [])) > 0
    error_message = "provider in us-east-1 must define default_tags"
  }
}
