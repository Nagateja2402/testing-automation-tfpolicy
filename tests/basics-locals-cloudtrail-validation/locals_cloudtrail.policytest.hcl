
policytest {
  targets = ["locals_cloudtrail.policy.hcl"]
}

resource "aws_cloudtrail" "validation_enabled_passes" {
  expect_failure = false
  attrs = {
    enable_log_file_validation = true
  }
}

resource "aws_cloudtrail" "validation_disabled_fails" {
  expect_failure = true
  attrs = {
    enable_log_file_validation = false
  }
}
