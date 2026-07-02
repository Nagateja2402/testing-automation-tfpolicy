
policytest {
  targets = ["delete_approval.policy.hcl"]
}

# Create: delete-only policy is skipped
resource "aws_s3_bucket" "create_skips_delete_only_policy" {
  expect_failure = false
  meta = {
    operation = "create"
  }
  attrs = {
    bucket = "my-bucket"
    tags   = {}
  }
}

# Update: delete-only policy is skipped
resource "aws_s3_bucket" "update_skips_delete_only_policy" {
  expect_failure = false
  meta = {
    operation = "update"
  }
  attrs = {
    bucket = "my-bucket"
  }
  prior_attrs = {
    bucket = "my-bucket"
    tags   = {}
  }
}
