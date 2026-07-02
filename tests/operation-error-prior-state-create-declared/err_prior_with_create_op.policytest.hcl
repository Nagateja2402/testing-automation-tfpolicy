# Note: meta.operation="create" with prior_attrs present is not a validation error;
# the create-only policy evaluates (tag is present) and passes.
# The engine does not enforce that prior_attrs is absent on create.

policytest {
  targets = ["err_prior_with_create_op.policy.hcl"]
}

resource "aws_s3_bucket" "prior_attrs_with_create_op_passes" {
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
  prior_attrs = {
    bucket = "old-bucket"
  }
}
