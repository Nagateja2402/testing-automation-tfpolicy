
policytest {
  targets = ["dms_endpoint_valid.policy.hcl"]
}

resource "aws_dms_endpoint" "fully_specified_passes" {
  expect_failure = false
  attrs = {
    endpoint_id = "my-endpoint"
    engine_name = "mysql"
    ssl_mode    = "require"
  }
}

resource "aws_dms_endpoint" "missing_ssl_mode_fails" {
  expect_failure = true
  attrs = {
    endpoint_id = "my-endpoint"
    engine_name = "mysql"
  }
}

resource "aws_dms_endpoint" "invalid_engine_fails" {
  expect_failure = true
  attrs = {
    endpoint_id = "my-endpoint"
    engine_name = "oracle"
    ssl_mode    = "require"
  }
}
