resource "aws_vpc" "msk_vpc" {
  cidr_block = var.vpc_cidr
  tags = merge(
    local.common-tags,
    map(
      "Name", "msk-${lower(var.environment)}-vpc",
      "Description", "VPC for creating MSK resources",
    )
  )
}