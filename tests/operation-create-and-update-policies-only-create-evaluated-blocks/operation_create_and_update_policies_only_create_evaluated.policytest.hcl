policytest {
  targets = ["operation_create_and_update_policies_only_create_evaluated.policy.hcl"]
}

resource "aws_s3_bucket" "create_denied" {
  expect_failure = true
  attrs = {
    bucket = "operation-create-and-update-polici-q"
  }
  meta = {
    operation = "create"
  }
}

resource "aws_s3_bucket" "noop_skips_both" {
  expect_failure = false
  attrs = {
    bucket = "operation-create-and-update-polici-q"
  }
  meta = {
    operation = "no-op"
  }
}
