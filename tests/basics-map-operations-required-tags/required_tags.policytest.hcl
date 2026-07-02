
policytest {
  targets = ["required_tags.policy.hcl"]
}

resource "aws_instance" "both_tags_pass" {
  expect_failure = false
  attrs = {
    instance_type = "t3.medium"
    tags = {
      name        = "web-server"
      environment = "production"
    }
  }
}

resource "aws_instance" "missing_environment_fails" {
  expect_failure = true
  attrs = {
    instance_type = "t3.medium"
    tags = {
      name = "web-server"
    }
  }
}
