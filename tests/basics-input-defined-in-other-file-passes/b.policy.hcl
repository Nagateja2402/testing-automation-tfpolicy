# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "env_in_name" {
  enforce {
    condition     = input.environment == "prod"
    error_message = "environment input is ${input.environment}"
  }
}
