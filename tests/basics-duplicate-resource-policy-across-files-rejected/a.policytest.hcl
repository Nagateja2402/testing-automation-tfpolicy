policytest {
  targets = ["a.policy.hcl"]
}

resource "aws_s3_bucket" "b" {
  expect_failure = false
  attrs = {
    bucket = "basics-duplicate-resource-policy-a-bucket-nagateja"
  }
}
