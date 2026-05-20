
policytest {
  targets = ["infer_delete.policy.hcl"]
}

# Only prior_attrs provided — operation inferred as "delete"; policy evaluates and passes.
resource "aws_s3_bucket" "prior_only_inferred_as_delete_passes" {
  expect_failure = false
  prior_attrs = {
    bucket = "my-bucket"
    tags = {
      DeletionApproved = "true"
    }
  }
}
