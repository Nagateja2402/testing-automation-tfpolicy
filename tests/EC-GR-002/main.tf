# EC-GR-002: getresources indexed beyond bounds — core::try prevents panic.
# Policy: checks if flow_logs[5].traffic_type == "ALL" (out of bounds → "NONE" via try → FAIL).
# At plan time: attrs.id is unknown → UNKNOWN
# At apply time: getresources returns 1 flow log; index 5 out of bounds → try returns "NONE" → FAIL

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "ec-gr-002-flow-logs"
  retention_in_days = 7
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "ec-gr-002-vpc" }
}

resource "aws_flow_log" "main" {
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  iam_role_arn         = "arn:aws:iam::992382722822:role/AmazonBedrockAgentCoreSDKRuntime-us-east-1-764090f73a"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_log.arn
}
