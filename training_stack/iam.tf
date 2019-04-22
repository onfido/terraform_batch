resource "aws_iam_role" "ec2" {
  name = "${var.prefix}${var.name}-ec2"

  assume_role_policy = "${data.aws_iam_policy_document.ec2.json}"
}

data "aws_iam_policy_document" "ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.prefix}${var.name}-ec2"
  role = "${aws_iam_role.ec2.name}"
}

resource "aws_iam_role_policy_attachment" "ec2_ecs" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ec2_s3" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

resource "aws_iam_role_policy_attachment" "ec2_ecr" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "${aws_iam_policy.ecr.arn}"
}

# ############################################

resource "aws_iam_role" "batch" {
  name = "${var.prefix}${var.name}-batch"

  assume_role_policy = "${data.aws_iam_policy_document.batch.json}"
}

data "aws_iam_policy_document" "batch" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "batch_service_role" {
  role       = "${aws_iam_role.batch.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

# #############################################

resource "aws_iam_role" "ecs_tasks" {
  name = "${var.prefix}${var.name}-ecs-tasks"

  assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks.json}"
}

data "aws_iam_policy_document" "ecs_tasks" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = "${aws_iam_role.ecs_tasks.name}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

# #############################################

resource "aws_iam_role" "spotfleet" {
  name = "${var.prefix}${var.name}-spotfleet"

  assume_role_policy = "${data.aws_iam_policy_document.spotfleet.json}"
}

data "aws_iam_policy_document" "spotfleet" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "spotfleet" {
  role       = "${aws_iam_role.spotfleet.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole"
}

# #############################################

resource "aws_iam_policy" "s3" {
  name   = "${var.prefix}${var.name}-s3"
  policy = "${data.aws_iam_policy_document.s3.json}"
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = ["s3:*"]

    resources = [
      "${aws_s3_bucket.b.arn}",
      "${aws_s3_bucket.b.arn}/*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "s3:List*",
      "s3:GetObject",
      "s3:HeadObject",
    ]

    effect = "Allow"
  }

  statement {
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.k.arn}"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy" "ecs_s3_external" {
  count = "${length(var.external_s3_buckets) > 0 ? 1 : 0}"

  role   = "${aws_iam_role.ecs_tasks.name}"
  name   = "${var.prefix}${var.name}-ecs-s3-external"
  policy = "${data.aws_iam_policy_document.s3_external.json}"
}

resource "aws_iam_role_policy" "ec2_s3_external" {
  count = "${length(var.external_s3_buckets) > 0 ? 1 : 0}"

  role   = "${aws_iam_role.ec2.name}"
  name   = "${var.prefix}${var.name}-ec2-s3-external"
  policy = "${data.aws_iam_policy_document.s3_external.json}"
}

data "aws_iam_policy_document" "s3_external" {
  count = "${length(var.external_s3_buckets) > 0 ? 1 : 0}"

  statement {
    actions = [
      "s3:List*",
      "s3:GetObject",
      "s3:HeadObject",
    ]

    resources = [
      "${var.external_s3_buckets}",
      "${formatlist("%s/*", var.external_s3_buckets)}",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy" "ecs_kms_external" {
  count = "${length(var.external_kms_keys) > 0 ? 1 : 0}"

  role   = "${aws_iam_role.ecs_tasks.name}"
  name   = "${var.prefix}${var.name}-ecs-kms-external"
  policy = "${data.aws_iam_policy_document.kms_external.json}"
}

resource "aws_iam_role_policy" "ec2_kms_external" {
  count = "${length(var.external_kms_keys) > 0 ? 1 : 0}"

  role   = "${aws_iam_role.ec2.name}"
  name   = "${var.prefix}${var.name}-ec2-kms-external"
  policy = "${data.aws_iam_policy_document.kms_external.json}"
}

data "aws_iam_policy_document" "kms_external" {
  count = "${length(var.external_kms_keys) > 0 ? 1 : 0}"

  statement {
    actions   = ["kms:Decrypt"]
    resources = ["${var.external_kms_keys}"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "ecr" {
  name = "${var.prefix}${var.name}-ecr"

  policy = "${data.aws_iam_policy_document.ecr.json}"
}

data "aws_iam_policy_document" "ecr" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
    ]

    resources = ["${aws_ecr_repository.ecr.arn}"]

    effect = "Allow"
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]

    effect = "Allow"
  }
}
