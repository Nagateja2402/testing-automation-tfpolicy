policytest {
  targets = ["module_policy_attrs_map_missing_key_defers_unknown.policy.hcl"]
}

module "./modules/q" "q" {
  expect_failure = true
  attrs = {
    name = "module-policy-attrs-map-missing-ke-q"
    tags = { env = "dev" }
  }
  meta = {
    source = "./modules/q"
    address = "module.q"
  }
}
