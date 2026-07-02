
policytest {
  targets = ["plan_unknown_apply_allow.policy.hcl"]
}

# Pass: VPC has an associated flow log
resource "aws_flow_log" "main" {
  skip = true
  attrs = {
    vpc_id       = "vpc-gr-plan-004-pass"
    traffic_type = "ALL"
  }
}

resource "aws_vpc" "pass_has_flow_log" {
  expect_failure = false
  attrs = {
    id         = "vpc-gr-plan-004-pass"
    cidr_block = "10.0.0.0/16"
  }
}

# Fail: VPC has no associated flow log
resource "aws_vpc" "fail_no_flow_log" {
  expect_failure = true
  attrs = {
    id         = "vpc-gr-plan-004-fail"
    cidr_block = "10.1.0.0/16"
  }
}
