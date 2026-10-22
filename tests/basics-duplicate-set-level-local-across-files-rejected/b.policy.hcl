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
  allowed_regions = ["us-west-2"]
}

provider_policy "aws" "region" {
  enforce {
    condition = core::contains(local.allowed_regions, attrs.region)
  }
}
