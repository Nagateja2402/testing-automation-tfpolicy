policytest {
  targets = ["basics_timestamp_invalid_date.policy.hcl"]
}

resource "aws_ssm_parameter" "bad_date" {
  expect_failure = true
  attrs = {
    name = "/basics-timestamp-invalid-date-erro/expiry"
    type = "String"
    value = "not-a-date"
  }
}
