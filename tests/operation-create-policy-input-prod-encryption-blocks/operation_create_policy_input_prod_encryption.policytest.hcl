policytest {
  targets = ["operation_create_policy_input_prod_encryption.policy.hcl"]
}

resource "aws_s3_bucket" "unencrypted" {
  expect_failure = true
  attrs = {
    bucket = "operation-create-policy-input-prod-q"
    tags = { encryption = "none" }
  }
  meta = {
    operation = "create"
  }
}

resource "aws_s3_bucket" "encrypted" {
  expect_failure = false
  attrs = {
    bucket = "operation-create-policy-input-prod-q2"
    tags = { encryption = "kms" }
  }
  meta = {
    operation = "create"
  }
}
