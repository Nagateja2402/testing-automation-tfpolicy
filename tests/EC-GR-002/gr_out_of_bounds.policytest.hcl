# Note: getresources returns 0 or 1 elements; index [5] is out of bounds.
# core::try returns "NONE" → condition fails → policy denies. No panic.

policytest {
  targets = ["gr_out_of_bounds.policy.hcl"]
}

resource "aws_flow_log" "fixture" {
  skip = true
  attrs = {
    vpc_id       = "vpc-abc123"
    traffic_type = "ALL"
  }
}

resource "aws_vpc" "out_of_bounds_fails_gracefully" {
  expect_failure = true
  attrs = {
    id         = "vpc-abc123"
    cidr_block = "10.0.0.0/16"
  }
}
