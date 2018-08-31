
output "master.ip" {
  value = "${aws_instance.master.public_ip}"
}


output "slave0.ip" {
  value = "${aws_instance.slave.0.public_ip}"
}

output "slave1.ip" {
  value = "${aws_instance.slave.1.public_ip}"
}
