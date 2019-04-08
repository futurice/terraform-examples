# Create an AWS Virtual Private Cloud (VPC)
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true                                                     # https://stackoverflow.com/a/33443018
  tags                 = "${merge(var.aws_tags, map("Name", "${var.vpc_name}"))}"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"
  tags   = "${var.aws_tags}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "this" {
  gateway_id             = "${aws_internet_gateway.this.id}"
  route_table_id         = "${aws_vpc.this.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "this" {
  availability_zone       = "${data.aws_availability_zones.this.names[0]}" # use the first available AZ in the region (AWS ensures this is constant per user)
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags                    = "${var.aws_tags}"
}
