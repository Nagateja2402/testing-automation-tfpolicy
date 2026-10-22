policytest {
  targets = ["basics_policy_scoped_locals_repeat_across_policies.policy.hcl"]
}

resource "aws_s3_bucket" "q" {
  expect_failure = false
  attrs = {
    bucket = "basics-policy-scoped-locals-repeat-q"
  }
}
