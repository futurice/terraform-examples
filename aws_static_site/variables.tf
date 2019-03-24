variable "site_domain" {
  description = "Domain on which the static site will be made available (e.g. 'www.example.com')"
}

variable "name_prefix" {
  description = "Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed, for S3 bucket name compatibility)"
  default     = "aws-static-site---"
}

variable "bucket_override" {
  description = "Set this to 'true' if you don't want an S3 bucket created automatically"
  default     = false                                                                     # note: https://www.terraform.io/docs/configuration/variables.html#booleans
}

variable "bucket_override_name" {
  description = "When 'bucket_override' is enabled, use this to set the name of the bucket that should be used (e.g. 'my-bucket')"
  default     = ""
}

variable "price_class" {
  description = "Price class to use (100, 200 or All, see https://aws.amazon.com/cloudfront/pricing/)"
  default     = "100"
}

variable "cache_ttl_override" {
  description = "When >= 0, override the cache behaviour for ALL objects in S3, so that they stay in the CloudFront cache for this amount of seconds"
  default     = -1
}

variable "default_root_object" {
  description = "The object to return when the root URL is requested"
  default     = "index.html"
}

locals {
  prefix_with_domain = "${var.name_prefix}${replace("${var.site_domain}", "/[^a-z0-9-]+/", "-")}"                    # only lowercase alphanumeric characters and hyphens are allowed in S3 bucket names
  bucket_name        = "${var.bucket_override == 0 ? "${local.prefix_with_domain}" : "${var.bucket_override_name}"}" # select between externally-provided or auto-generated bucket names
  bucket_domain_name = "${local.bucket_name}.s3-website.${data.aws_region.current.name}.amazonaws.com"               # use current region to complete the domain name (we can't use the "aws_s3_bucket" data source because the bucket may not initially exist)
}
