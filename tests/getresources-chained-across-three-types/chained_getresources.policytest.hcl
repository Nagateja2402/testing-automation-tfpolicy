
policytest {
  targets = ["chained_getresources.policy.hcl"]
}

resource "aws_s3_bucket_logging" "main_logging" {
  skip = true
  attrs = {
    bucket        = "my-primary-bucket"
    target_bucket = "my-logging-bucket"
    target_prefix = "logs/"
  }
}

resource "aws_s3_bucket" "logging_bucket" {
  skip = true
  attrs = {
    bucket = "my-logging-bucket"
  }
}

resource "aws_s3_bucket" "pass_has_logging" {
  expect_failure = false
  attrs = {
    bucket = "my-primary-bucket"
  }
}
