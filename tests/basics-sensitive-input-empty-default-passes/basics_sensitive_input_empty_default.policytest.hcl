policytest {
  targets = ["basics_sensitive_input_empty_default.policy.hcl"]
}

resource "aws_s3_bucket" "no_token" {
  expect_failure = false
  attrs = {
    bucket = "basics-sensitive-input-empty-defau-q"
    }
}
