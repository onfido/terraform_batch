variable "prefix" {
  default = "tf-"
}

variable "name" {}

variable "environment_resources" {
  type = "map"
}

variable "environment_definition" {}

variable "configuration" {
  type = "map"
}

variable "external_s3_buckets" {
  type    = "list"
  default = []
}

variable "external_kms_keys" {
  type    = "list"
  default = []
}
