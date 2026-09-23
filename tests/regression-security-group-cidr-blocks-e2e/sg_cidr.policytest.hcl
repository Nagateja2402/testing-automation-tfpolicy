policytest {
  targets = ["sg_cidr.policy.hcl"]
}

resource "aws_security_group" "restricted_passes" {
  expect_failure = false
  attrs = {
    name = "restricted-sg"
    ingress = [
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"] },
    ]
  }
  meta = { provider_type = "aws" }
}
