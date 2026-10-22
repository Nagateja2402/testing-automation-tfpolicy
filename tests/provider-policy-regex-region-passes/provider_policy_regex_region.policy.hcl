# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

provider_policy "aws" "region_regex" {
  enforce {
    condition     = core::regex_match(attrs.region, "^us-(east|west)-[0-9]$")
    error_message = "provider region '${attrs.region}' does not match ^us-(east|west)-[0-9]$"
  }
}
