# Note: wrong type for filter value (number vs string) — expect empty result, no panic.

policytest {
  targets = ["gr_wrong_type_filter.policy.hcl"]
}

resource "aws_flow_log" "fixture" {
  skip = true
  attrs = {
    vpc_id       = "vpc-abc123"
    traffic_type = "ALL"
  }
}

resource "aws_vpc" "wrong_type_filter_no_panic" {
  expect_failure = false
  attrs = {
    id         = "vpc-abc123"
    cidr_block = "10.0.0.0/16"
  }
}
