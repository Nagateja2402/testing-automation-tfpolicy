# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "terraform_*" "input_must_be_prod" {
  operations = ["create"]
  enforce {
    condition     = core::try(attrs.input, "") == "prod"
    error_message = "terraform_data input must be prod"
  }
}
