# Note: file-level default is advisory, but resource_policy overrides to mandatory.
# Denial is therefore mandatory and blocks the run.

policytest {
  targets = ["enforcement_override.policy.hcl"]
}

resource "aws_s3_bucket" "mandatory_override_blocks_despite_advisory_default" {
  expect_failure = true
  attrs = {
    bucket             = "my-bucket"
    versioning_enabled = false
  }
}
