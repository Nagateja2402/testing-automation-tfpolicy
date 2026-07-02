
policytest {
  targets = ["provider_region.policy.hcl"]
}

provider "aws" "approved_region_us_east_1" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
  }
}

provider "aws" "approved_region_us_west_2" {
  expect_failure = false
  attrs = {
    region = "us-west-2"
  }
}

provider "aws" "approved_region_eu_west_1" {
  expect_failure = false
  attrs = {
    region = "eu-west-1"
  }
}
