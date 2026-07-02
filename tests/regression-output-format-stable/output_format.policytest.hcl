
policytest {
  targets = ["output_format.policy.hcl"]
}

resource "aws_s3_bucket" "output_format_pass" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "staging"
    }
  }
}
