policytest {
  targets = ["basics_resource_undefined_local.policy.hcl"]
}

resource "aws_s3_bucket" "q" {
  expect_failure = false
  attrs = {
    bucket = "basics-resource-undefined-local-re-q"
  }
}
