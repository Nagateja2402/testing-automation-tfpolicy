
policytest {
  targets = ["provider_region.policy.hcl"]
}

provider "aws" "disallowed_region_ap_southeast_1" {
  expect_failure = true
  attrs = {
    region = "ap-southeast-1"
  }
}

provider "aws" "disallowed_region_sa_east_1" {
  expect_failure = true
  attrs = {
    region = "sa-east-1"
  }
}
