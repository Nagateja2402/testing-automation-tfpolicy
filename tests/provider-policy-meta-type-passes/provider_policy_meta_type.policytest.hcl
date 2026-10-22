policytest {
  targets = ["provider_policy_meta_type.policy.hcl"]
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
