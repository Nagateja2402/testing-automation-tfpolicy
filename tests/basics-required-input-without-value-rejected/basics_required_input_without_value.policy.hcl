# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "required_region" {
  type = string
}

provider_policy "aws" "init_setup_error" {
  enforce {
    condition     = attrs.region == input.required_region
    error_message = "region mismatch"
  }
}
