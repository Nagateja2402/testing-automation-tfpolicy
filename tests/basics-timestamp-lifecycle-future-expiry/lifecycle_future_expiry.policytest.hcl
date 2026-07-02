
policytest {
  targets = ["lifecycle_future_expiry.policy.hcl"]
}

resource "aws_s3_bucket_lifecycle_configuration" "future_date_passes" {
  expect_failure = false
  attrs = {
    rule = [{
      expiration = [{ date = "2999-12-31" }]
    }]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "past_date_fails" {
  expect_failure = true
  attrs = {
    rule = [{
      expiration = [{ date = "2000-01-01" }]
    }]
  }
}
