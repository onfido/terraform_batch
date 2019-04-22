resource "aws_batch_job_definition" "j" {
  name = "${var.prefix}${var.name}"
  type = "container"

  container_properties = <<CONTAINER_PROPERTIES
{
    "image": "${aws_ecr_repository.ecr.repository_url}:latest",
    "vcpus": ${var.environment_resources["vcpus"]},
    "memory": ${var.environment_resources["memory"]},
    ${var.environment_definition},

    "command": ["/home/${var.name}/extraction/start_training.sh"],

    "jobRoleArn": "${aws_iam_role.ecs_tasks.arn}",
    "mountPoints": [
      {
        "sourceVolume": "training-data",
        "readOnly": false,
        "containerPath": "/var/data/training"
      },
      {
        "sourceVolume": "training-logs",
        "readOnly": false,
        "containerPath": "/var/log/training"
      }
    ],
    "volumes": [
      {
        "host": {"sourcePath": "/var/data/training"},
        "name": "training-data"
      },
      {
        "host": {"sourcePath": "/var/log/training"},
        "name": "training-logs"
      }
    ],
    "ulimits": []
}
CONTAINER_PROPERTIES
}
