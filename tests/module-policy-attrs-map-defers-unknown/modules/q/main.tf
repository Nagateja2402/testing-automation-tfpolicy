variable "name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
resource "aws_s3_bucket" "q" {
  bucket = var.name
  tags = var.tags
}
