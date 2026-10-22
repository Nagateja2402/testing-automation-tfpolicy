policytest {
  targets = ["ec2.policy.hcl"]
}

resource "aws_instance" "dev_instance" {
  expect_failure = true
  attrs = {
    ami = "ami-0c02fb55956c7d316"
    instance_type = "t3.micro"
    tags = { env = "dev" }
  }
}

resource "aws_instance" "prod_instance" {
  expect_failure = false
  attrs = {
    ami = "ami-0c02fb55956c7d316"
    instance_type = "t3.micro"
    tags = { env = "prod" }
  }
}
