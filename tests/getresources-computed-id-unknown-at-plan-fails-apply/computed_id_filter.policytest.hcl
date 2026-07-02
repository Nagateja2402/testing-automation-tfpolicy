
policytest {
  targets = ["computed_id_filter.policy.hcl"]
}

# Pass: bucket has a matching logging config (id matches attrs.id of the bucket)
resource "aws_s3_bucket_logging" "primary" {
  skip = true
  attrs = {
    id     = "gr-plan-001-primary-bucket-xyz"
    bucket = "gr-plan-001-primary-bucket-xyz"
  }
}

resource "aws_s3_bucket" "pass_has_logging" {
  expect_failure = false
  attrs = {
    id     = "gr-plan-001-primary-bucket-xyz"
    bucket = "gr-plan-001-primary-bucket-xyz"
  }
}

# Fail: bucket has no matching logging config
resource "aws_s3_bucket" "fail_no_logging" {
  expect_failure = true
  attrs = {
    id     = "gr-plan-001-orphan-bucket-xyz"
    bucket = "gr-plan-001-orphan-bucket-xyz"
  }
}
