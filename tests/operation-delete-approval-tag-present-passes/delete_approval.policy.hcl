# Copyright (c) HashiCorp, Inc.
# Delete-only policy: confirms approved-deletion tag is present.

policy {}

resource_policy "aws_s3_bucket" "delete_requires_approval_tag" {
  operations = ["delete"]

  enforce {
    condition     = core::try(prior_attrs.tags.DeletionApproved, "false") == "true"
    error_message = "S3 bucket must have DeletionApproved=true tag before deletion"
  }
}
