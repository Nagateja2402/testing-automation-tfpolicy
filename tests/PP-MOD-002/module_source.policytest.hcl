
policytest {
  targets = ["module_source.policy.hcl"]
}

module "github.com/acme/vpc" "unapproved_source_fails" {
  expect_failure = true
  meta = {
    source = "github.com/acme/vpc"
  }
}

module "./modules/unapproved" "another_unapproved_source_fails" {
  expect_failure = true
  meta = {
    source = "./modules/unapproved"
  }
}
