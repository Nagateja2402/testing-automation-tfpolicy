
policytest {
  targets = ["ternary_instance_type.policy.hcl"]
}

resource "aws_instance" "prod_correct_type_passes" {
  expect_failure = false
  attrs = {
    instance_type = "m5.xlarge"
    tags = { environment = "production" }
  }
}

resource "aws_instance" "prod_wrong_type_fails" {
  expect_failure = true
  attrs = {
    instance_type = "t3.medium"
    tags = { environment = "production" }
  }
}

resource "aws_instance" "nonprod_correct_type_passes" {
  expect_failure = false
  attrs = {
    instance_type = "t3.medium"
    tags = { environment = "dev" }
  }
}
