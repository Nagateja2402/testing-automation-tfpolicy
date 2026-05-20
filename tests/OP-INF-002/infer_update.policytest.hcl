
policytest {
  targets = ["infer_update.policy.hcl"]
}

# Both attrs and prior_attrs provided without explicit meta.operation — inferred as "update".
resource "aws_s3_bucket" "attrs_and_prior_inferred_as_update_passes" {
  expect_failure = false
  attrs = {
    bucket = "same-bucket-name"
  }
  prior_attrs = {
    bucket = "same-bucket-name"
  }
}
