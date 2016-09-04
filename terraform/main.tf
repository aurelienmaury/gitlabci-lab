provider "aws" {}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }
  tags {
    Name = "Main route table for ${var.vpc_name} VPC"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.main.id}"
}


resource "aws_iam_role" "ami_building_role" {
  name = "ami_service_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ami_building_policy" {

  name = "ami_service_policy"

  role = "${aws_iam_role.ami_building_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ami_building_instance_profile" {
  name = "ami_service_instance_profile"
  roles = ["${aws_iam_role.ami_building_role.name}"]
}

module "zone_a" {
  source = "github.com/WeScale/tf-mod-aws-az"

  vpc_id = "${aws_vpc.vpc.id}"
  vpc_name = "${var.vpc_name}"
  availability_zone = "${var.az_1}"
  public_subnet_cidr = "${var.public_subnet_cidr_1}"
  private_subnet_cidr = "${var.private_subnet_cidr_1}"
  public_gateway_route_table_id = "${aws_route_table.main.id}"
}

resource "aws_instance" "bastion" {

  ami = "${var.bastion_ami_id}"
  instance_type = "${var.bastion_instance_type}"
  key_name = "${var.keypair}"
  subnet_id = "${module.zone_a.public_subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.bastions.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ami_building_instance_profile.id}"

  tags {
    Name = "builder-${var.vpc_name}-${var.az_1}"
    Bastion_realm_sg_id = "${aws_security_group.bastion_realm.id}"
  }
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc = true
}

resource "aws_security_group" "bastions" {
  name = "service_bastions"
  description = "Allow SSH traffic from the internet"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_realm" {
  name = "service_bastion_realm"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastions.id}"]
  }
}
