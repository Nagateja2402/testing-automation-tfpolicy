
policytest {
  targets = ["provider_targeted.policy.hcl"]
}

# aws provider in approved region — passes the policy
provider "aws" "aws_approved_region_passes" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
  }
  meta = {
    type   = "aws"
  }
}

# aws provider in disallowed region — correctly denied
provider "aws" "aws_disallowed_region_fails" {
  expect_failure = true
  attrs = {
    region = "ap-southeast-1"
  }
  meta = {
    type   = "aws"
  }
}
