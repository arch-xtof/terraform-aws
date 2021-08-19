variable "aws_access_key" {
}
variable "aws_secret_key" {}
variable "subnet_prefix" {}
variable "vpc_prefix" {}
variable "default_region" {}
variable "default_ami" {}
variable "default_instance_type" {}
variable "default_availability_zone" {}
variable "default_ssh_key" {}
variable "number_of_vms" {}
variable "bucket-name" {}
locals {
  timestamp = "${timestamp()}"
}
