
policytest {
  targets = ["immutable_field.policy.hcl"]
}

resource "aws_s3_bucket" "update_changes_bucket_name_fails" {
  expect_failure = true
  meta = {
    operation = "update"
  }
  attrs = {
    bucket = "new-bucket-name"
  }
  prior_attrs = {
    bucket = "old-bucket-name"
  }
}
