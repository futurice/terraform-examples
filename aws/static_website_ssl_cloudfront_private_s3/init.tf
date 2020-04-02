provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

terraform {
  required_version = "~> 0.12"
}

provider "aws" {
  alias   = "us_east_1" #cloudfront needs acm certificate to be from "us-east-1" region
  region  = "us-east-1"
  version = "~> 2.0"
}
