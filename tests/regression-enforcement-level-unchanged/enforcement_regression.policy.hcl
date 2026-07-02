# Copyright (c) HashiCorp, Inc.
# REG-BIN-009: Enforcement levels unchanged on new binary.
# Advisory denial must remain a pass, mandatory denial must remain a fail.

policy {}

resource_policy "aws_s3_bucket" "advisory_check" {
  enforcement_level = "advisory"

  enforce {
    condition     = core::try(attrs.versioning_enabled, false) == true
    error_message = "Advisory: versioning should be enabled"
  }
}

resource_policy "aws_s3_bucket" "mandatory_check" {
  enforcement_level = "mandatory"

  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "Mandatory: Environment tag is required"
  }
}
