policytest {
  targets = ["empty_state.policy.hcl"]
}

# Both attrs and prior_attrs absent → no real lifecycle change. tfpolicy 0.3.0
# rejects this fixture up front instead of vacuously passing zero policies.
resource "aws_s3_bucket" "no_state_declared" {
  expect_failure = false
}
