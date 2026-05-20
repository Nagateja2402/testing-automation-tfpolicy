# EXPECT_OUTPUT: ERROR_CONTAINS: EC-ENF-003: Environment tag is missing

policytest {
  targets = ["error_message_fail.policy.hcl"]
}

resource "aws_s3_bucket" "failing_condition_error_message_shown" {
  expect_failure = true
  attrs = {
    bucket = "my-bucket"
    tags   = {}
  }
}
