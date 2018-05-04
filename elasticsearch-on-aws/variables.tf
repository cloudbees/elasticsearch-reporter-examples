variable "region" {
  description = "The AWS region to use"
}
variable "availability_zone" {
  description = ""
}
variable "vpc_cidr_block" {
  description = ""
  default = "172.31.0.0/16"
}
variable "ami" {
  description = "AWS AMI to use for the launched (Ubuntu) VMs"
  default = "ami-cd0f5cb6"
}
variable "instance_type" {
  description = "AWS Virtual Machine type to use"
  default = "t2.medium"
}
variable "tag_vm_owner" {
  description = "AWS tag indicating owner of launched VMs"
}
variable "tag_vm_type" {
  description = "AWS tag indicating type to use for launched VMs"
  default = "cluster"
}
variable "key_name" {
  description = "Name of the SSH key to be used"
}
variable "gateway_name" {
  description = "Prefix for the gateway names"
}
variable "gateway_ip_list" {
  description = "The list of ES master/gateway IP addresses"
  default = []
}
variable "server_name" {
  description = "Prefix for the server names"
}
variable "server_ip_list" {
  description = "The list of ES data server IP addresses"
  default = []
}
