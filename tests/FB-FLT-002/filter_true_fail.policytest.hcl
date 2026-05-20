
policytest {
  targets = ["filter_true_fail.policy.hcl"]
}

# Production bucket: filter=true → enforce runs and fails because versioning is disabled.
resource "aws_s3_bucket" "prod_filter_true_enforce_fails" {
  expect_failure = true
  attrs = {
    bucket = "prod-bucket"
    tags = {
      Environment = "production"
    }
    versioning_enabled = false
  }
}
