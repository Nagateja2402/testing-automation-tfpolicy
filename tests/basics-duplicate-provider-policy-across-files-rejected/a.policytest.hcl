policytest {
  targets = ["a.policy.hcl"]
}

provider "aws" "east" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
  }
}
