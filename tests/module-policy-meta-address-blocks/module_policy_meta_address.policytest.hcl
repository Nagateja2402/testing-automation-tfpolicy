policytest {
  targets = ["module_policy_meta_address.policy.hcl"]
}

module "./modules/s3" "s3q" {
  expect_failure = true
  meta = {
    source = "./modules/s3"
    address = "module.s3q"
  }
}
