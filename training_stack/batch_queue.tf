resource "aws_batch_job_queue" "q" {
  compute_environments = ["${aws_batch_compute_environment.bce.arn}"]
  name                 = "${var.prefix}${var.name}"
  priority             = 1
  state                = "ENABLED"
}
