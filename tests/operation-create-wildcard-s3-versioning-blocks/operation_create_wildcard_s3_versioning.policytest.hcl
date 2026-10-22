policytest {
  targets = ["operation_create_wildcard_s3_versioning.policy.hcl"]
}

resource "aws_s3_bucket" "versioning_off" {
  expect_failure = true
  attrs = {
    bucket = "operation-create-wildcard-s3-versi-bucket-nagateja"
    versioning = [{ enabled = false }]
  }
  meta = {
    operation = "create"
  }
}

resource "aws_s3_bucket" "versioning_on" {
  expect_failure = false
  attrs = {
    bucket = "operation-create-wildcard-s3-versi-bucket-nagateja"
    versioning = [{ enabled = true }]
  }
  meta = {
    operation = "create"
  }
}
