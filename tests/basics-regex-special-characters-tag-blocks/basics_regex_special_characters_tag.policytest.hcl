policytest {
  targets = ["basics_regex_special_characters_tag.policy.hcl"]
}

resource "aws_s3_bucket" "special_chars" {
  expect_failure = true
  attrs = {
    bucket = "basics-regex-special-characters-ta-q"
    tags = { Name = "caf\u00e9 \"q\" <x>&'日本 \\d" }
  }
}

resource "aws_s3_bucket" "plain" {
  expect_failure = false
  attrs = {
    bucket = "basics-regex-special-characters-ta-q2"
    tags = { Name = "plain-name_1.0" }
  }
}
