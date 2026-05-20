
policytest {
  targets = ["unknown_resource_type.policy.hcl"]
}

resource "aws_s3_bucket" "fail_no_companion" {
  expect_failure = true
  attrs = {
    bucket = "my-bucket"
  }
}
