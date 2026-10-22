policytest {
  targets = ["operation_create_policy_locals_allowed_tiers.policy.hcl"]
}

resource "aws_s3_bucket" "bronze" {
  expect_failure = true
  attrs = {
    bucket = "operation-create-policy-locals-all-q"
    tags = { tier = "bronze" }
  }
  meta = {
    operation = "create"
  }
}

resource "aws_s3_bucket" "gold" {
  expect_failure = false
  attrs = {
    bucket = "operation-create-policy-locals-all-q2"
    tags = { tier = "gold" }
  }
  meta = {
    operation = "create"
  }
}
