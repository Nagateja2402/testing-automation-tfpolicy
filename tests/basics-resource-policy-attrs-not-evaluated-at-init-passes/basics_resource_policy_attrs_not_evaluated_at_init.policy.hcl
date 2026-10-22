# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "uses_attrs" {
  filter = core::startswith(attrs.bucket, "basics-resource-policy-attrs-not-e-")
  enforce {
    condition     = attrs.bucket == "basics-resource-policy-attrs-not-e-q"
    error_message = "unexpected bucket name"
  }
}
