
policytest {
  targets = ["topo_order.policy.hcl"]
}

resource "aws_flow_log" "main" {
  skip = true
  attrs = {
    vpc_id       = "vpc-abc123"
    traffic_type = "ALL"
  }
}

resource "aws_vpc" "with_flow_log_passes" {
  expect_failure = false
  attrs = {
    id         = "vpc-abc123"
    cidr_block = "10.0.0.0/16"
  }
}

resource "aws_flow_log" "evaluated" {
  expect_failure = false
  attrs = {
    vpc_id       = "vpc-abc123"
    traffic_type = "ALL"
  }
}
