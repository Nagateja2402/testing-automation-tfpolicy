# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "no_force_destroy" {
  enforce {
    condition     = attrs.force_destroy == false
    error_message = "bucket force_destroy must be false"
  }
}
