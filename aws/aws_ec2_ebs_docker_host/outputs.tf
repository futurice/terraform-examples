output "hostname" {
  description = "Hostname by which this service is identified in metrics, logs etc"
  value       = "${var.hostname}"
}

output "public_ip" {
  description = "Public IP address assigned to the host by EC2"
  value       = "${aws_instance.this.public_ip}"
}

output "instance_id" {
  description = "AWS ID for the EC2 instance used"
  value       = "${aws_instance.this.id}"
}

output "availability_zone" {
  description = "AWS Availability Zone in which the EC2 instance was created"
  value       = "${local.availability_zone}"
}

output "ssh_username" {
  description = "Username that can be used to access the EC2 instance over SSH"
  value       = "${var.ssh_username}"
}

output "ssh_private_key_path" {
  description = "Path to SSH private key that can be used to access the EC2 instance"
  value       = "${var.ssh_private_key_path}"
}

output "ssh_private_key" {
  description = "SSH private key that can be used to access the EC2 instance"
  value       = "${file("${var.ssh_private_key_path}")}"
}

output "security_group_id" {
  description = "Security Group ID, for attaching additional security rules externally"
  value       = "${aws_security_group.this.id}"
}
