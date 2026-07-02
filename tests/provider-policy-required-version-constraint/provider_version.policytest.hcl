
policytest {
  targets = ["provider_version.policy.hcl"]
}

provider "aws" "version_not_set" {
  expect_failure = true
  meta = {
    type = "aws"
  }
}

provider "aws" "version_pinned_passes" {
  expect_failure = false
  meta = {
    type    = "aws"
    version = "5.0.0"
  }
}
