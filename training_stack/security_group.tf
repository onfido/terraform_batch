resource "aws_security_group" "ec2" {
  name_prefix = "${var.prefix}${var.name}-ec2-"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Security group for batch jobs"

  ingress {
    ...
  }

  egress {
    ...
  }

  tags = {
    Name = "${var.prefix}${var.name}-ec2"
  }
}
