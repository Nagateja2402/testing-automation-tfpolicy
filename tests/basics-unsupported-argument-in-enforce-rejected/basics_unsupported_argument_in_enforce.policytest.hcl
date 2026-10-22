policytest {
  targets = ["basics_unsupported_argument_in_enforce.policy.hcl"]
}

provider "aws" "east" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
  }
}
