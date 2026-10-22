policytest {
  targets = ["operation_meta_operation_in_enforce_create.policy.hcl"]
}

resource "aws_s3_bucket" "create_passes" {
  expect_failure = false
  attrs = {
    bucket = "operation-meta-operation-in-enforc-q"
  }
  meta = {
    operation = "create"
  }
}

resource "aws_s3_bucket" "update_fails" {
  expect_failure = true
  attrs = {
    bucket = "operation-meta-operation-in-enforc-q"
  }
  prior_attrs = {
    bucket = "operation-meta-operation-in-enforc-q"
  }
  meta = {
    operation = "update"
  }
}
