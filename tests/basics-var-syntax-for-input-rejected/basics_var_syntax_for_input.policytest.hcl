policytest {
  targets = ["basics_var_syntax_for_input.policy.hcl"]
}

resource "aws_s3_bucket" "q" {
  expect_failure = false
  attrs = {
    bucket = "basics-var-syntax-for-input-reject-q"
    tags = { env = "prod" }
  }
}
