# Note: duplicate values in operations list is a validation error.
# tfpcli validate exits non-zero with "Duplicate operation" error.

policytest {
  targets = ["op_duplicate.policy.hcl"]
}

resource "aws_s3_bucket" "create_with_tag_duplicate_ops" {
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
