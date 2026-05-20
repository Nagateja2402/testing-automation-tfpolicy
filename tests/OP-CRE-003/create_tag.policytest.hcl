
policytest {
  targets = ["create_tag.policy.hcl"]
}

# Update operation — create-only policy should be skipped even though tag is missing.
resource "aws_s3_bucket" "update_skips_create_only_policy" {
  expect_failure = false
  meta = {
    operation = "update"
  }
  attrs = {
    bucket = "my-bucket"
    tags   = {}
  }
  prior_attrs = {
    bucket = "my-bucket"
    tags   = {}
  }
}
