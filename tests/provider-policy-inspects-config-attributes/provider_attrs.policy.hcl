# Copyright (c) HashiCorp, Inc.
# This policy intentionally uses attrs in a provider_policy context,
# which is not allowed at the setup evaluation stage. Expected to cause
# a validation/compile error when evaluated.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
provider_policy "aws" "invalid_attrs_in_provider_policy" {
  enforce {
    condition     = core::try(attrs.region, "") == "us-east-1"
    error_message = "Provider region must be us-east-1"
  }
}
