# Copyright (c) HashiCorp, Inc.
# EC-OP: tfpolicy 0.3.0 rejects a resource test case whose attrs and
# prior_attrs are both absent/empty (previously such a case inferred no
# operation, evaluated zero policies, and passed vacuously).

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "empty_state_rejected" {
  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "Environment tag required"
  }
}
