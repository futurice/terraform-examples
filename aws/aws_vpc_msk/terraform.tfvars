aws_region  = "us-east-1"
environment = "Prod"
application = "acm"

vpc_cidr             = "192.168.8.0/21"
private_subnet_cidrs = ["192.168.8.0/24", "192.168.10.0/24", "192.168.12.0/24"]
public_subnet_cidrs  = ["192.168.9.0/26", "192.168.11.0/26", "192.168.13.0/26"]

