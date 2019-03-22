variable "redirect_domain" {
  description = "Domain which will redirect to the given 'redirect_url'; e.g. 'docs.example.com'"
}

variable "redirect_url" {
  description = "The URL this domain redirect should send clients to; e.g. 'https://readthedocs.org/projects/example'"
}

variable "bucket_prefix" {
  description = "Name prefix to use for the S3 bucket that's created internally for the redirect (only lowercase alphanumeric characters and hyphens allowed)"
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
