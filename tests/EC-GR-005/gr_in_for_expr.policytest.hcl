
policytest {
  targets = ["gr_in_for_expr.policy.hcl"]
}

resource "aws_flow_log" "fixture" {
  skip = true
  attrs = {
    vpc_id       = "vpc-abc123"
    traffic_type = "ALL"
  }
}

resource "aws_vpc" "for_expr_finds_all_traffic_type_passes" {
  expect_failure = false
  attrs = {
    id         = "vpc-abc123"
    cidr_block = "10.0.0.0/16"
  }
}

resource "aws_vpc" "for_expr_no_all_traffic_type_fails" {
  expect_failure = true
  attrs = {
    id         = "vpc-xyz999"
    cidr_block = "10.1.0.0/16"
  }
}
