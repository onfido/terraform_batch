resource "aws_kms_key" "k" {
  enable_key_rotation = true

  tags {
    Name = "${var.prefix}${var.name}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "a" {
  name = "alias/${var.name}"

  target_key_id = "${aws_kms_key.k.key_id}"
}
