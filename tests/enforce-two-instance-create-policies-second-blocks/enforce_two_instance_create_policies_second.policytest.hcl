policytest {
  targets = ["enforce_two_instance_create_policies_second.policy.hcl"]
}

resource "aws_instance" "i" {
  expect_failure = true
  attrs = {
    ami = "ami-0c02fb55956c9d604"
    instance_type = "t3.micro"
  }
  meta = {
    operation = "create"
  }
}
