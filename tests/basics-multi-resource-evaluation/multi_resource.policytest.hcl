
policytest {
  targets = ["multi_resource.policy.hcl"]
}

resource "aws_instance" "allowed_type_passes" {
  expect_failure = false
  attrs = {
    instance_type = "t3.medium"
  }
}

resource "aws_instance" "t2_micro_fails" {
  expect_failure = true
  attrs = {
    instance_type = "t2.micro"
  }
}
