
policytest {
  targets = ["infer_create.policy.hcl"]
}

# Only attrs provided — operation inferred as "create"; policy evaluates and passes.
resource "aws_s3_bucket" "attrs_only_inferred_as_create_passes" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "dev"
    }
  }
}
