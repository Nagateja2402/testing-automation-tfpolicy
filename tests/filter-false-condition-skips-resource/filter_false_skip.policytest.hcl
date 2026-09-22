
policytest {
  targets = ["filter_false_skip.policy.hcl"]
}

# Non-production bucket: filter=false → enforce skipped → passes even without versioning.
resource "aws_s3_bucket" "non_prod_filter_false_skips_enforce" {
  expect_failure = false
  attrs = {
    bucket = "dev-bucket"
    tags = {
      Environment = "dev"
    }
    versioning = [{ enabled = false }]
  }
}
