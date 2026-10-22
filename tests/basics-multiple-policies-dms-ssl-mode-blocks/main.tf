# basics-multiple-policies-dms-ssl-mode-blocks: 3 separate resource_policies on aws_dms_endpoint: engine/endpoint_id pass, ssl_mode=none fails with its own message
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_dms_endpoint" "e" {
  endpoint_id   = "basics-multiple-policies-dms-ssl-m-ep"
  endpoint_type = "source"
  engine_name   = "mysql"
  server_name   = "db.example.com"
  port          = 3306
  username      = "u"
  password      = "Passw0rd123"
  ssl_mode      = "none"
}
