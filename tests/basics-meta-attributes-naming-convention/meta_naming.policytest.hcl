
policytest {
  targets = ["meta_naming.policy.hcl"]
}

resource "aws_instance" "web_frontend_valid" {
  expect_failure = false
  attrs = {
    instance_type = "t3.medium"
    tags = {
      Name = "web-frontend-001"
    }
  }
  meta = {
    provider_type = "aws"
  }
}

resource "aws_instance" "bad_name_fails" {
  expect_failure = true
  attrs = {
    instance_type = "t3.medium"
    tags = {
      Name = "badname"
    }
  }
  meta = {
    provider_type = "aws"
  }
}
