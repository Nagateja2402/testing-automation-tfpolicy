
policytest {
  targets = ["delete_approval.policy.hcl"]
}

resource "aws_s3_bucket" "delete_without_approval_tag_fails" {
  expect_failure = true
  meta = {
    operation = "delete"
  }
  attrs = {}
  prior_attrs = {
    bucket = "my-bucket"
    tags   = {}
  }
}
