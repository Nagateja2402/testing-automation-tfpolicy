policytest {
  targets = ["operation_create_meta_operation_force_destroy.policy.hcl"]
}

resource "aws_s3_bucket" "force_destroy_off" {
  expect_failure = true
  attrs = {
    bucket = "operation-create-meta-operation-fo-q"
    force_destroy = false
  }
  meta = {
    operation = "create"
  }
}

resource "aws_s3_bucket" "force_destroy_on" {
  expect_failure = false
  attrs = {
    bucket = "operation-create-meta-operation-fo-q2"
    force_destroy = true
  }
  meta = {
    operation = "create"
  }
}
