# Creating stack 1 - Copy/Paste for new stack
module "training_stack_1" {
  source = "../modules/training_stack"
  name   = "training-stack-1"

  # External bucket access outside this stack
  # external_s3_buckets = [
  #   "${module.external-bucket.bucket["arn"]}",
  # ]

  environment_resources = {
    memory = 40000
    vcpus  = 7
  }

  configuration = {
    instance_type = "p3.2xlarge"
    max_vcpus     = 128
    min_vcpus     = 0
    type          = "SPOT"

    image_id = "ami-xxx"
  }

  environment_definition = <<EOF
  "environment": [
      { "name": "PYTHONPATH", "value": "." },
      { "name": "TRAINING_ID", "value": "<training id>" },
      { "name": "TRAINING_PATH", "value": "DATASETS/train" },
      { "name": "TEST_PATH", "value": "DATASETS/test" },
      { "name": "NUMBER_GPUS", "value": "1" },
      { "name": "NUM_EPOCH", "value": "100" },
      { "name": "INTERVAL_STEPS", "value": "10" },
    ]
  EOF
}
