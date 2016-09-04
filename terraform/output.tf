output "bastion_ip" {
  value = "${aws_eip.bastion.public_ip}"
}