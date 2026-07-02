
policytest {
  targets = ["meta_naming.policy.hcl"]
}

resource "aws_instance" "web_frontend_valid" {
  expect_failure = false
  attrs = {
    instance_type = "t3.medium"
  }
  meta = {
    name = "web-frontend-001"
  }
}

resource "aws_instance" "bad_name_fails" {
  expect_failure = true
  attrs = {
    instance_type = "t3.medium"
  }
  meta = {
    name = "badname"
  }
}
