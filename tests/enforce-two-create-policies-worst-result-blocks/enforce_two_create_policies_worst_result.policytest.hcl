policytest {
  targets = ["enforce_two_create_policies_worst_result.policy.hcl"]
}

resource "aws_s3_bucket" "q" {
  expect_failure = true
  attrs = {
    bucket = "enforce-two-create-policies-worst-q"
  }
  meta = {
    operation = "create"
  }
}
