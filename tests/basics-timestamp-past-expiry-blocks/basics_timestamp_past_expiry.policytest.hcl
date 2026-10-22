policytest {
  targets = ["basics_timestamp_past_expiry.policy.hcl"]
}

resource "aws_ssm_parameter" "expired" {
  expect_failure = true
  attrs = {
    name = "/basics-timestamp-past-expiry-block/expiry"
    type = "String"
    value = "2020-01-01T00:00:00Z"
  }
}

resource "aws_ssm_parameter" "valid" {
  expect_failure = false
  attrs = {
    name = "/basics-timestamp-past-expiry-block/ok"
    type = "String"
    value = "2099-01-01T00:00:00Z"
  }
}
