
policytest {
  targets = ["large_policy.policy.hcl"]
}

resource "aws_s3_bucket" "all_tags_present_passes" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
    tags = {
      Tag01 = "a"
      Tag02 = "b"
      Tag03 = "c"
      Tag04 = "d"
      Tag05 = "e"
      Tag06 = "f"
      Tag07 = "g"
      Tag08 = "h"
      Tag09 = "i"
      Tag10 = "j"
    }
  }
}
