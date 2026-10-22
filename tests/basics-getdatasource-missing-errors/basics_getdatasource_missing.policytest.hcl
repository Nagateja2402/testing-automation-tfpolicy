policytest {
  targets = ["basics_getdatasource_missing.policy.hcl"]
}

resource "aws_s3_bucket" "q" {
  expect_failure = true
  attrs = {
    bucket = "basics-getdatasource-missing-error-q"
    }
}
