
policytest {
  targets = ["e2e_create_pass.policy.hcl"]
}

resource "aws_vpc" "tagged_vpc_passes" {
  expect_failure = false
  attrs = {
    id         = "vpc-abc123"
    cidr_block = "10.0.0.0/16"
    tags = {
      Environment = "dev"
    }
  }
}
