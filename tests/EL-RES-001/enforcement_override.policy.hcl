# Copyright (c) HashiCorp, Inc.
# Policy-level enforcement_level overrides the file-level default.
# The policy block sets default enforcement; resource_policy overrides it.

policy {
  enforcement_level = "advisory"
}

resource_policy "aws_s3_bucket" "policy_override_to_mandatory" {
  enforcement_level = "mandatory"

  enforce {
    condition     = core::try(attrs.versioning_enabled, false) == true
    error_message = "This policy overrides advisory default with mandatory enforcement"
  }
}
