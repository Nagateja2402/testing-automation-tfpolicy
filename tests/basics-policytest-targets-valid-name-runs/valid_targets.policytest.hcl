policytest {
  targets = ["valid_targets.policy.hcl"]
}

resource "aws_s3_bucket" "ok" {
  expect_failure = false
  attrs = { bucket = "some-bucket" }
  meta  = { provider_type = "aws" }
}

resource "aws_s3_bucket" "fail_empty_bucket" {
  expect_failure = true
  attrs = { bucket = "" }
  meta  = { provider_type = "aws" }
}
