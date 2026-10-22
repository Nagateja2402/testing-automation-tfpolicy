policytest {
  targets = ["filter_input_mismatch_skips_policy.policy.hcl"]
}

resource "aws_dms_endpoint" "postgres_skipped" {
  expect_failure = false
  attrs = {
    endpoint_id = "filter-input-mismatch-skips-policy-endpoint"
    engine_name = "postgres"
    endpoint_type = "source"
  }
}
