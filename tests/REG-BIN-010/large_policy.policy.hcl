# Copyright (c) HashiCorp, Inc.
# REG-BIN-010: Large policy file performance on new binary.
# Contains many resource_policy blocks to test for performance regressions.

policy {}

resource_policy "aws_s3_bucket" "check_01" {
  enforce {
    condition     = core::try(attrs.tags.Tag01, "") != ""
    error_message = "Tag01 required"
  }
}

resource_policy "aws_s3_bucket" "check_02" {
  enforce {
    condition     = core::try(attrs.tags.Tag02, "") != ""
    error_message = "Tag02 required"
  }
}

resource_policy "aws_s3_bucket" "check_03" {
  enforce {
    condition     = core::try(attrs.tags.Tag03, "") != ""
    error_message = "Tag03 required"
  }
}

resource_policy "aws_s3_bucket" "check_04" {
  enforce {
    condition     = core::try(attrs.tags.Tag04, "") != ""
    error_message = "Tag04 required"
  }
}

resource_policy "aws_s3_bucket" "check_05" {
  enforce {
    condition     = core::try(attrs.tags.Tag05, "") != ""
    error_message = "Tag05 required"
  }
}

resource_policy "aws_s3_bucket" "check_06" {
  enforce {
    condition     = core::try(attrs.tags.Tag06, "") != ""
    error_message = "Tag06 required"
  }
}

resource_policy "aws_s3_bucket" "check_07" {
  enforce {
    condition     = core::try(attrs.tags.Tag07, "") != ""
    error_message = "Tag07 required"
  }
}

resource_policy "aws_s3_bucket" "check_08" {
  enforce {
    condition     = core::try(attrs.tags.Tag08, "") != ""
    error_message = "Tag08 required"
  }
}

resource_policy "aws_s3_bucket" "check_09" {
  enforce {
    condition     = core::try(attrs.tags.Tag09, "") != ""
    error_message = "Tag09 required"
  }
}

resource_policy "aws_s3_bucket" "check_10" {
  enforce {
    condition     = core::try(attrs.tags.Tag10, "") != ""
    error_message = "Tag10 required"
  }
}
