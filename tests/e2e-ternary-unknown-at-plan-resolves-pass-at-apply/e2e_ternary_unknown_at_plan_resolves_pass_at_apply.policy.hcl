# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "terraform_data" "ternary_unknown" {
  filter = core::try(attrs.input["Check"], "") == "yes"
  enforce {
    condition     = attrs.input["Mode"] == "prod" ? attrs.input["Delay"] == "0" : true
    error_message = "prod entries must have Delay 0"
  }
}
