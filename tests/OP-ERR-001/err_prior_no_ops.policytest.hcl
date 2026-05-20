# Note: prior_attrs in a test block (with inferred update operation) is valid;
# the engine evaluates the update-scoped policy and the condition passes
# (same bucket name). No validation error is produced.

policytest {
  targets = ["err_prior_no_ops.policy.hcl"]
}

resource "aws_s3_bucket" "prior_attrs_inferred_update_passes" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
  }
  prior_attrs = {
    bucket = "my-bucket"
  }
}
