
policytest {
  targets = ["immutable_field.policy.hcl"]
}

# Create operation — update-only policy is skipped; prior_attrs won't match but policy is not evaluated.
resource "aws_s3_bucket" "create_skips_update_only_policy" {
  expect_failure = false
  meta = {
    operation = "create"
  }
  attrs = {
    bucket = "new-bucket"
  }
}
