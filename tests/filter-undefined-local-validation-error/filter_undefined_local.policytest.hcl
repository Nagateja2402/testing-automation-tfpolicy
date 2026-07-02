
policytest {
  targets = ["filter_undefined_local.policy.hcl"]
}

resource "aws_s3_bucket" "filter_undefined_local_validation_error" {
  expect_failure = true
  attrs = {
    bucket             = "my-bucket"
    versioning_enabled = true
  }
}
