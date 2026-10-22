policytest {
  targets = ["enforce_error_and_info_message_both_present.policy.hcl"]
}

resource "aws_s3_bucket" "q" {
  expect_failure = true
  attrs = {
    bucket = "enforce-error-and-info-message-bot-q"
  }
}
