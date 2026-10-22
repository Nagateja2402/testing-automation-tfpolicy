# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_*" "versioning_required" {
  operations = ["create"]
  enforce {
    condition     = core::try(attrs.versioning[0].enabled, false) == true
    error_message = "S3 bucket versioning must be enabled"
  }
}
