# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

provider_policy "aws" "attrs_region_unset" {
  enforce {
    condition     = attrs.region == "us-east-1"
    error_message = "region must be us-east-1"
  }
}
