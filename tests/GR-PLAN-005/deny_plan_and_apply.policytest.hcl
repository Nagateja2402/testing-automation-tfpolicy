
policytest {
  targets = ["deny_plan_and_apply.policy.hcl"]
}

# Fail: VPC has no associated flow log — no aws_flow_log resources present
resource "aws_vpc" "fail_no_flow_log" {
  expect_failure = true
  attrs = {
    id         = "vpc-gr-plan-005-no-flowlog"
    cidr_block = "10.0.0.0/16"
  }
}
