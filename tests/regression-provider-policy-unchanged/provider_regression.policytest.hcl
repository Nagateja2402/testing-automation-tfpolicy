
policytest {
  targets = ["provider_regression.policy.hcl"]
}

provider "aws" "approved_region_regression_passes" {
  expect_failure = false
  meta = {
    type   = "aws"
    region = "us-east-1"
  }
}
