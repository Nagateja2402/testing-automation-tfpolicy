# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

provider_policy "aws" "multi_enforce" {
  enforce {
    condition     = meta.type == "aws"
    error_message = "enforce1: provider type must be aws"
  }
  enforce {
    condition     = attrs.region == "eu-west-1"
    error_message = "enforce2: provider region must be eu-west-1"
  }
}
