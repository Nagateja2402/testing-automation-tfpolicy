# enforce-two-instance-create-policies-second-blocks: two aws_instance create policies: first passes, second fails -> deny with second message
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }

resource "aws_instance" "i" {
  ami           = "ami-0c02fb55956c9d604"
  instance_type = "t3.micro"
}
