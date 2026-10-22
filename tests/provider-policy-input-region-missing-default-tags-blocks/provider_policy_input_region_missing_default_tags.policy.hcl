# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "region" {
  type    = string
  default = "us-east-1"
}

provider_policy "aws" "input_region_needs_tags" {
  filter = attrs.region == input.region
  enforce {
    condition     = core::length(core::try(attrs.default_tags, [])) > 0
    error_message = "provider in region ${input.region} must define default_tags"
  }
}
