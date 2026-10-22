policytest {
  targets = ["module_policy_filter_address.policy.hcl"]
}

module "./modules/s3" "s3_match" {
  expect_failure = false
  meta = {
    source = "./modules/s3"
    address = "module.s3_match"
  }
}

module "./modules/s3" "s3_other" {
  expect_failure = false
  meta = {
    source = "./modules/s3"
    address = "module.s3_other"
  }
}
