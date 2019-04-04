variable "redirect_domain" {
  description = "Domain which will redirect to the given `redirect_url`; e.g. `\"docs.example.com\"`"
}

variable "redirect_url" {
  description = "The URL this domain redirect should send clients to; e.g. `\"https://readthedocs.org/projects/example\"`"
}

variable "name_prefix" {
  description = "Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed, for S3 bucket name compatibility)"
  default     = "aws-domain-redirect---"
}

variable "comment_prefix" {
  description = "This will be included in comments for resources that are created"
  default     = "Domain redirect: "
}

variable "redirect_price_class" {
  description = "Price class to use (`100`, `200` or `\"All\"`, see https://aws.amazon.com/cloudfront/pricing/)"
  default     = 100
}

variable "redirect_permanently" {
  description = "Which HTTP status code to use for the redirect; if `true`, uses `301 Moved Permanently`, instead of `302 Found`"
  default     = false
}

variable "redirect_with_hsts" {
  description = "Whether to send the `Strict-Transport-Security` header with the redirect (recommended for security)"
  default     = true
}

variable "lambda_logging_enabled" {
  description = "When `true`, writes information about incoming requests to the Lambda function's CloudWatch group"
  default     = false
}
