# Note: mandatory_overridable behaves like mandatory in tfpolicy test;
# the override mechanism applies at the Terraform run level, not at test level.

policytest {
  targets = ["mandatory_overridable.policy.hcl"]
}

resource "aws_s3_bucket" "overridable_deny_fails_in_test" {
  expect_failure = true
  attrs = {
    bucket             = "my-bucket"
    versioning_enabled = false
  }
}
