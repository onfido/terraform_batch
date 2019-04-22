resource "aws_s3_bucket" "b" {
  bucket = "onfido-${var.name}"

  lifecycle {
    prevent_destroy = true
  }
}
