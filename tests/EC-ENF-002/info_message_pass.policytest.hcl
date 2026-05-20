
policytest {
  targets = ["info_message_pass.policy.hcl"]
}

resource "aws_s3_bucket" "passing_condition_info_message_shown" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "dev"
    }
  }
}
