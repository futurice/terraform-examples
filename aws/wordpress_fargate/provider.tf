provider "aws" {
  version = "~> 2.0"
}

terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "wordpress"
  }
}

provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  version = "~> 2.0"
}

provider "random" {
  version = "~> 2.2"
}
