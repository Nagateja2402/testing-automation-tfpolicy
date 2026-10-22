variable "name" { type = string }
variable "delay" { type = number }
variable "timeout" {
  type    = number
  default = 30
}

resource "aws_s3_bucket" "this" {
  bucket = var.name
  tags = {
    delay   = tostring(var.delay)
    timeout = tostring(var.timeout)
  }
}
