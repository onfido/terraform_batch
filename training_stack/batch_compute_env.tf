resource "aws_batch_compute_environment" "bce" {
  compute_environment_name = "${var.prefix}${var.name}-${random_id.bce.dec}"

  compute_resources {
    image_id = "${var.configuration["image_id"]}"

    instance_role = "${aws_iam_instance_profile.ec2.arn}"

    instance_type = ["${var.configuration["instance_type"]}"]

    bid_percentage = 99

    max_vcpus     = "${var.configuration["max_vcpus"]}"
    min_vcpus     = "${var.configuration["min_vcpus"]}"
    desired_vcpus = "${var.configuration["min_vcpus"]}"
    type          = "${var.configuration["type"]}"
    ec2_key_pair  = "${aws_key_pair.k.key_name}"

    security_group_ids = [
      "${aws_security_group.ec2.id}",
      "${data.terraform_remote_state.vpc.default_security_group}",
    ]

    subnets = [
      "${data.terraform_remote_state.vpc.subnets.app}",
    ]

    spot_iam_fleet_role = "${aws_iam_role.spotfleet.arn}"
  }

  service_role = "${aws_iam_role.batch.arn}"
  type         = "MANAGED"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["compute_resources.0.desired_vcpus"]
  }
}

resource "random_id" "bce" {
  keepers {
    type          = "${var.configuration["type"]}"
    instance_type = "${var.configuration["instance_type"]}"
    image_id      = "${var.configuration["image_id"]}"
    key_pair      = "${aws_key_pair.k.key_name}"
    subnets       = "${join(",", data.terraform_remote_state.vpc.subnets.app)}"
  }

  byte_length = 8
}
