
policytest {
  targets = ["vpc_flow_log.policy.hcl"]
}

resource "aws_flow_log" "main" {
  skip = true
  attrs = {
    vpc_id       = "vpc-abc123"
    traffic_type = "ALL"
  }
}

resource "aws_vpc" "pass_has_flow_log" {
  expect_failure = false
  attrs = {
    id         = "vpc-abc123"
    cidr_block = "10.0.0.0/16"
  }
}
