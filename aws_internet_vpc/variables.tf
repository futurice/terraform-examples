variable "vpc_name" {
  description = "Name given to the VPC; in addition to human-readability, can be used to fetch this VPC using a `aws_vpc` data block"
  default     = "terraform-default-vpc"
}

variable "tags" {
  description = "AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/"
  type        = "map"
  default     = {}
}
