policytest {
  targets = ["module_policy_regex_address.policy.hcl"]
}

module "./modules/q" "Bad_Name" {
  expect_failure = true
  meta = {
    source = "./modules/q"
    address = "module.Bad_Name"
  }
}
