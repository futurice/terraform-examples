terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "wordpress"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"

  default_tags {
    tags = var.tags
  }
}
