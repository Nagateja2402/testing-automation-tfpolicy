policytest {
  targets = ["module_policy_multiple_calls_one_bad.policy.hcl"]
}

module "./modules/q" "q_a" {
  expect_failure = false
  meta = {
    source = "./modules/q"
    address = "module.q_a"
  }
}

module "./modules/q" "q_b" {
  expect_failure = false
  meta = {
    source = "./modules/q"
    address = "module.q_b"
  }
}

module "./modules/q" "q_bad" {
  expect_failure = true
  meta = {
    source = "./modules/q"
    address = "module.q_bad"
  }
}
