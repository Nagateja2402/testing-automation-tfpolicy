
policytest {
  targets = ["all_ops.policy.hcl"]
}

# Update operation — tag missing → policy fails
resource "aws_s3_bucket" "update_missing_tag_fails" {
  expect_failure = true
  meta = {
    operation = "update"
  }
  attrs = {
    bucket = "my-bucket"
    tags   = {}
  }
  prior_attrs = {
    bucket = "my-bucket"
    tags = {
      ResourceName = "my-bucket"
    }
  }
}
