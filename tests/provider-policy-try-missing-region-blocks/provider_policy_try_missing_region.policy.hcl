# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

provider_policy "aws" "region_default" {
  enforce {
    condition     = core::try(attrs.region, "") == "us-east-1"
    error_message = "provider region must be us-east-1 (missing region falls back to empty default)"
  }
}
