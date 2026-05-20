
policytest {
  targets = ["preexisting_pass.policy.hcl"]
}

resource "aws_s3_bucket" "bucket_with_env_tag_passes" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "dev"
    }
  }
}
