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

provider_policy "aws" "input_region" {
  filter = attrs.region == input.region
  enforce {
    condition     = attrs.region == input.region
    error_message = "provider region must equal input.region"
  }
}
