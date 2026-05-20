
policytest {
  targets = ["preexisting_fail.policy.hcl"]
}

resource "aws_s3_bucket" "bucket_without_env_tag_fails" {
  expect_failure = true
  attrs = {
    bucket = "my-bucket"
    tags   = {}
  }
}
