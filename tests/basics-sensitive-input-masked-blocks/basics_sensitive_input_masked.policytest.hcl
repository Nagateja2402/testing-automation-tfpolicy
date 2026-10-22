policytest {
  targets = ["basics_sensitive_input_masked.policy.hcl"]
}

resource "aws_s3_bucket" "different_token" {
  expect_failure = true
  attrs = {
    bucket = "basics-sensitive-input-masked-bloc-q"
      tags = { Token = "different" }
  }
}
