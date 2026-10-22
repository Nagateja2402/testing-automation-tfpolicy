# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

provider_policy "aws" "region_filter" {
  filter = attrs.region == "us-east-1"
  enforce {
    condition     = attrs.region == "us-east-1"
    error_message = "filtered provider must be us-east-1"
  }
}
