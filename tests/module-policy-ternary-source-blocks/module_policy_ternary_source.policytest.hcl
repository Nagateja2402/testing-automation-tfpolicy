policytest {
  targets = ["module_policy_ternary_source.policy.hcl"]
}

module "./modules/q" "q" {
  expect_failure = true
  meta = {
    source = "./modules/q"
    address = "module.q"
  }
}

module "./modules/q" "other" {
  expect_failure = false
  meta = {
    source = "./modules/q"
    address = "module.other"
  }
}
