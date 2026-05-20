# Copyright (c) HashiCorp, Inc.
# Delete-only policy; verify NOT evaluated on create or update.

policy {}

resource_policy "aws_s3_bucket" "delete_requires_approval_tag" {
  operations = ["delete"]

  enforce {
    condition     = core::try(prior_attrs.tags.DeletionApproved, "false") == "true"
    error_message = "S3 bucket must have DeletionApproved=true tag before deletion"
  }
}
