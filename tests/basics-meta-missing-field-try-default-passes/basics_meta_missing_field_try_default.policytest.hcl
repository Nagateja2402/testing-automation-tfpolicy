policytest {
  targets = ["basics_meta_missing_field_try_default.policy.hcl"]
}

resource "aws_s3_bucket" "q" {
  expect_failure = false
  attrs = {
    bucket = "basics-meta-missing-field-try-defa-q"
  }
  meta = {
    operation = "create"
  }
}
