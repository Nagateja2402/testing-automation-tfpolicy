# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

provider_policy "aws" "multi_alias" {
  enforce {
    condition     = core::contains(["us-east-1", "us-west-2", "us-east-2"], attrs.region)
    error_message = "provider region '${attrs.region}' not allowed"
  }
}
