
policytest {
  targets = ["module_source.policy.hcl"]
}

module "./modules/vpc" "approved_source_passes" {
  expect_failure = false
  meta = {
    source = "./modules/vpc"
  }
}

module "./modules/s3" "another_approved_source_passes" {
  expect_failure = false
  meta = {
    source = "./modules/s3"
  }
}
