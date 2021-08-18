variable "aws_access_key" {
}
variable "aws_secret_key" {}
variable "subnet_prefix" {}
variable "vpc_prefix" {}
variable "local_ips" {}
variable "default_region" {}
variable "default_ami" {}
variable "default_instance_type" {}
variable "default_availability_zone" {}
variable "default_ssh_key" {}

locals {
  timestamp = "${timestamp()}"
}
