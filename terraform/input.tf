variable "vpc_name" {}

variable "vpc_cidr" {}

variable "amis" {
  default = {
    eu-west-1 = "ami-e079f893"
  }
}

variable "az_1" {}

variable "private_subnet_cidr_1" {}

variable "public_subnet_cidr_1" {}

variable "keypair" {}

variable "bastion_ami_id" {}

variable "bastion_instance_type" {}

variable "bastion_keypair" {}
