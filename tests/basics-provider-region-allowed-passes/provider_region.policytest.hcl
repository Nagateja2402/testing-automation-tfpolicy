
policytest {
  targets = ["provider_region.policy.hcl"]
}

provider "aws" "allowed_region_passes" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
  }
}

provider "aws" "disallowed_region_fails" {
  expect_failure = true
  attrs = {
    region = "ap-south-1"
  }
}
