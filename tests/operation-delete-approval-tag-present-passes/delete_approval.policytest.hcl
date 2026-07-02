
policytest {
  targets = ["delete_approval.policy.hcl"]
}

resource "aws_s3_bucket" "delete_with_approval_tag_passes" {
  expect_failure = false
  meta = {
    operation = "delete"
  }
  attrs = {}
  prior_attrs = {
    bucket = "my-bucket"
    tags = {
      DeletionApproved = "true"
    }
  }
}
