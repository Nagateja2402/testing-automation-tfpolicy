policytest {
  targets = ["basics_init_safe_provider_and_plan_attrs_resource.policy.hcl"]
}

provider "aws" "aws" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
  }
  meta = {
    type = "aws"
  }
}

resource "aws_s3_bucket" "q" {
  expect_failure = false
  attrs = {
    bucket = "basics-init-safe-provider-and-plan-q"
  }
}
