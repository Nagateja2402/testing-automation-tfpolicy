
policytest {
  targets = ["create_tag.policy.hcl"]
}

resource "aws_s3_bucket" "create_without_environment_tag_fails" {
  expect_failure = true
  meta = {
    operation = "create"
  }
  attrs = {
    bucket = "my-bucket"
    tags   = {}
  }
}

resource "aws_s3_bucket" "create_with_no_tags_fails" {
  expect_failure = true
  meta = {
    operation = "create"
  }
  attrs = {
    bucket = "my-bucket"
  }
}
