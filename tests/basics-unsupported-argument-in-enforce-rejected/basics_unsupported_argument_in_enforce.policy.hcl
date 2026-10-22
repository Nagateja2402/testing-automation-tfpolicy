# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

provider_policy "aws" "init_syntax_error" {
  enforce {
    condition     = attrs.region == "us-east-1"
    bogus_attribute = "not supported"
  }
}
