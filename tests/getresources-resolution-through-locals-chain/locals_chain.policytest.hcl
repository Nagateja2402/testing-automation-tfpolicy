
policytest {
  targets = ["locals_chain.policy.hcl"]
}

resource "aws_s3_bucket_logging" "main_logging" {
  skip = true
  attrs = {
    bucket        = "my-primary-bucket"
    target_bucket = "my-logging-bucket"
    target_prefix = "logs/access/"
  }
}

resource "aws_s3_bucket" "pass_valid_logging_chain" {
  expect_failure = false
  attrs = {
    bucket = "my-primary-bucket"
  }
}
