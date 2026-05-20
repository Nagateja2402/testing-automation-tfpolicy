
policytest {
  targets = ["config_known_filter.policy.hcl"]
}

# Pass: bucket has a matching logging config (bucket name matches)
resource "aws_s3_bucket_logging" "primary" {
  skip = true
  attrs = {
    bucket        = "gr-plan-003-primary-bucket-xyz"
    target_bucket = "gr-plan-003-logging-bucket-xyz"
    target_prefix = "logs/"
  }
}

resource "aws_s3_bucket" "pass_has_logging" {
  expect_failure = false
  attrs = {
    id     = "gr-plan-003-primary-bucket-xyz"
    bucket = "gr-plan-003-primary-bucket-xyz"
  }
}

# Fail: bucket name does not match any logging config
resource "aws_s3_bucket" "fail_no_logging" {
  expect_failure = true
  attrs = {
    id     = "gr-plan-003-other-bucket-xyz"
    bucket = "gr-plan-003-other-bucket-xyz"
  }
}
