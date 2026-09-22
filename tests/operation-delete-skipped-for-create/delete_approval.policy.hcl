# Copyright (c) HashiCorp, Inc.
# Delete-only policy; verify NOT evaluated on create or update.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "delete_requires_approval_tag" {
  operations = ["delete"]

  enforce {
    condition     = core::try(prior_attrs.tags.DeletionApproved, "false") == "true"
    error_message = "S3 bucket must have DeletionApproved=true tag before deletion"
  }
}
