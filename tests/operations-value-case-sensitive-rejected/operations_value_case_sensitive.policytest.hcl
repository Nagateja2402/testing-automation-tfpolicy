policytest {
  targets = ["operations_value_case_sensitive.policy.hcl"]
}

resource "aws_s3_bucket" "q" {
  expect_failure = false
  attrs = {
    bucket = "operations-value-case-sensitive-re-q"
  }
}
