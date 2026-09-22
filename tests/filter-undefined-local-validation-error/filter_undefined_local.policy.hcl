# Copyright (c) HashiCorp, Inc.
# Filter references an undefined local — should produce a validation error.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "filter_undefined_local" {
  filter = local.undefined_variable == "production"

  enforce {
    condition     = core::try(attrs.versioning_enabled, false) == true
    error_message = "Versioning must be enabled"
  }
}
