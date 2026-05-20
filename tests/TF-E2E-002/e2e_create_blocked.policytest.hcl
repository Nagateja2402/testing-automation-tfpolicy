
policytest {
  targets = ["e2e_create_blocked.policy.hcl"]
}

resource "aws_vpc" "untagged_vpc_fails" {
  expect_failure = true
  attrs = {
    id         = "vpc-abc123"
    cidr_block = "10.0.0.0/16"
    tags       = {}
  }
}
