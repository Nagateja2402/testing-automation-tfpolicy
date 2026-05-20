
policytest {
  targets = ["multi_policy_getresources.policy.hcl"]
}

resource "aws_s3_bucket_logging" "main_logging" {
  skip = true
  attrs = {
    bucket        = "my-primary-bucket"
    target_bucket = "my-logging-bucket"
    target_prefix = "access-logs/"
  }
}

resource "aws_s3_bucket" "pass_both_policies" {
  expect_failure = false
  attrs = {
    bucket = "my-primary-bucket"
  }
}
