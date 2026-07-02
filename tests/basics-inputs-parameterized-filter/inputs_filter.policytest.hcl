
policytest {
  targets = ["inputs_filter.policy.hcl"]
}

resource "aws_dms_endpoint" "mysql_matches_input_passes" {
  expect_failure = false
  attrs = {
    engine_name = "mysql"
  }
}

resource "aws_dms_endpoint" "mongodb_skipped_by_filter" {
  expect_failure = false
  attrs = {
    engine_name = "mongodb"
  }
}
