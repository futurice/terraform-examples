output "vpc_id" {
  description = "ID of the created AWS VPC which e.g. EC2 machines can join"
  value       = "${aws_vpc.this.id}"
}

output "subnet_id" {
  description = "ID of the created AWS VPC subnet which e.g. EC2 machines can join"
  value       = "${aws_subnet.this.id}"
}

# Note: The pointless-looking dependency on a computed property of 'aws_vpc.this' allows you to
# conveniently depend on the 'vpc_name' output, so that it's available only once the VPC's created
output "vpc_name" {
  description = "Name tag of the VPC created"
  value       = "${var.vpc_name}${replace("${aws_vpc.this.id}", "/.*/", "")}"
}
