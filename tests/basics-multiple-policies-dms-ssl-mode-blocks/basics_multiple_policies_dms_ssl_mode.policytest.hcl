policytest {
  targets = ["basics_multiple_policies_dms_ssl_mode.policy.hcl"]
}

resource "aws_dms_endpoint" "ssl_none" {
  expect_failure = true
  attrs = {
    endpoint_id = "basics-multiple-policies-dms-ssl-m-ep"
    engine_name = "mysql"
    ssl_mode = "none"
  }
}

resource "aws_dms_endpoint" "all_ok" {
  expect_failure = false
  attrs = {
    endpoint_id = "basics-multiple-policies-dms-ssl-m-ep"
    engine_name = "mysql"
    ssl_mode = "require"
  }
}
