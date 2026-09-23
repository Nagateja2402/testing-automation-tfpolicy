policytest {
  targets = ["meta_only.policy.hcl"]
}

# meta.operation is set explicitly but neither attrs nor prior_attrs is
# declared. tfpolicy 0.3.0 rejects this instead of inferring a phantom
# delete with no state to evaluate.
resource "aws_s3_bucket" "meta_operation_only" {
  expect_failure = false
  meta = {
    operation = "delete"
  }
}
