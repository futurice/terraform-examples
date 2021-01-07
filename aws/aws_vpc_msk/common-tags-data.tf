locals {
  common-tags = {
    "project"          = "${upper("${substr("${var.aws-profile}", 0, 3)}")}"
    "platform"         = "${upper("${substr("${var.aws-profile}", 0, 3)}")}"
    "environment-type" = var.environment
    "business-domain"  = "na"
    "cost-center"      = "na"
    "tier"             = "private"
    "application"      = var.application
  }
}

data "aws_caller_identity" "current" {}
resource "random_uuid" "randuuid" {}