
policytest {
  targets = ["create_tag.policy.hcl"]
}

resource "aws_s3_bucket" "create_with_environment_tag_passes" {
  expect_failure = false
  meta = {
    operation = "create"
  }
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "dev"
    }
  }
}
