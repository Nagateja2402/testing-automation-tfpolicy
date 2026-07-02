
policytest {
  targets = ["vpc_flow_log_reject.policy.hcl"]
}

resource "aws_flow_log" "reject_only" {
  skip = true
  attrs = {
    vpc_id       = "vpc-reject"
    traffic_type = "REJECT"
  }
}

resource "aws_vpc" "fail_reject_traffic" {
  expect_failure = true
  attrs = {
    id         = "vpc-reject"
    cidr_block = "10.0.0.0/16"
  }
}
