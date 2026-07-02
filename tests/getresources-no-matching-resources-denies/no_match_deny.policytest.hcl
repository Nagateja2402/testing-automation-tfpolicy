
policytest {
  targets = ["no_match_deny.policy.hcl"]
}

# Pass: bucket has a companion bucket with '-companion' suffix
resource "aws_s3_bucket" "companion" {
  skip = true
  attrs = {
    id     = "gr-plan-006-main-bucket-xyz-companion"
    bucket = "gr-plan-006-main-bucket-xyz-companion"
  }
}

resource "aws_s3_bucket" "pass_has_companion" {
  expect_failure = false
  attrs = {
    id     = "gr-plan-006-main-bucket-xyz"
    bucket = "gr-plan-006-main-bucket-xyz"
  }
}

# Fail: bucket has no companion — no bucket with '-companion' suffix exists
resource "aws_s3_bucket" "fail_no_companion" {
  expect_failure = true
  attrs = {
    id     = "gr-plan-006-orphan-bucket-xyz"
    bucket = "gr-plan-006-orphan-bucket-xyz"
  }
}
