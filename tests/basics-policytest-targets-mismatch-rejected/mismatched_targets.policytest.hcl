# targets a policy file name that does not exist in this directory — this
# must now be reported as an error (mistyped target no longer silently runs
# nothing and reports success).
policytest {
  targets = ["does_not_exist.policy.hcl"]
}

resource "aws_s3_bucket" "ok" {
  expect_failure = false
  attrs = { bucket = "some-bucket" }
  meta  = { provider_type = "aws" }
}
