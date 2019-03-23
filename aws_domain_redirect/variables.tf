variable "redirect_domain" {
  description = "Domain which will redirect to the given 'redirect_url'; e.g. 'docs.example.com'"
}

variable "redirect_url" {
  description = "The URL this domain redirect should send clients to; e.g. 'https://readthedocs.org/projects/example'"
}

variable "name_prefix" {
  description = "Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed, for S3 bucket name compatibility)"
  default     = "aws-domain-redirect---"
}

variable "redirect_price_class" {
  description = "Price class to use (100, 200 or All, see https://aws.amazon.com/cloudfront/pricing/)"
  default     = "100"
}

variable "redirect_cache_ttl" {
  description = "How long (in seconds) to keep responses in CloudFront before requesting again from S3; this effectively dictates worst case update lag after making changes"
  default     = 10
}

variable "redirect_code" {
  description = "HTTP status code to use for the redirect; the common ones are 301 for 'Moved Permanently', and 302 for 'Moved Temporarily'"
  default     = 302
}

locals {
  prefix_with_domain = "${var.name_prefix}${replace("${var.redirect_domain}", "/[^a-z0-9-]+/", "-")}" # only lowercase alphanumeric characters and hyphens are allowed in S3 bucket names
}

# Because S3 routing rules expect the URL to be provided as components, we need to do a bit of URL "parsing"
locals {
  url_protocol = "${replace("${var.redirect_url}", "/^(?:(\\w+):\\/\\/).*/", "$1")}"
  url_hostname = "${replace("${var.redirect_url}", "/^(?:\\w+:\\/\\/)?([^/]+).*/", "$1")}"
  url_path     = "${replace("${var.redirect_url}", "/^(?:\\w+:\\/\\/)?[^/]+(?:\\/(.*)|$)/", "$1")}"
}
