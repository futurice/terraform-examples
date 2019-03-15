# Access data about available availability zones in the current region
data "aws_availability_zones" "this" {}

# Retrieve info about the VPC this host should join

data "aws_vpc" "this" {
  tags = {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnet" "this" {
  vpc_id = "${data.aws_vpc.this.id}"
}
