output "bastion_ip" {
  value = "${aws_eip.bastion.public_ip}"
}

output "runner_ip" {
  value = "${aws_instance.runner.private_ip}"
}
