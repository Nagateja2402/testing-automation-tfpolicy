policytest {
  targets = ["basics_resource_policy_attrs_not_evaluated_at_init.policy.hcl"]
}

resource "aws_s3_bucket" "q" {
  expect_failure = false
  attrs = {
    bucket = "basics-resource-policy-attrs-not-e-q"
  }
}

resource "aws_s3_bucket" "other_prefix_filtered" {
  expect_failure = false
  attrs = {
    bucket = "other-q"
  }
}
