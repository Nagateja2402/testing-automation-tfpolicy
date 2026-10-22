policytest {
  targets = ["basics_policy_local_conflicts_with_set_level_local.policy.hcl"]
}

resource "aws_s3_bucket" "q" {
  expect_failure = false
  attrs = {
    bucket = "basics-policy-local-conflicts-with-q"
  }
}
