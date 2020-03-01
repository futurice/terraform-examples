module "aws_reverse_proxy" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_reverse_proxy#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_reverse_proxy?ref=v11.0"

  # S3 website endpoints are only available over plain HTTP
  origin_url = "http://${local.bucket_domain_name}/"

  # Our S3 bucket will only allow requests containing this custom header
  origin_custom_header_name = "User-Agent"

  # Somewhat perplexingly, this is the "correct" way to ensure users can't bypass CloudFront on their way to S3 resources
  # https://abridge2devnull.com/posts/2018/01/restricting-access-to-a-cloudfront-s3-website-origin/
  origin_custom_header_value = "${random_string.s3_read_password.result}"

  site_domain            = "${var.site_domain}"
  name_prefix            = "${var.name_prefix}"
  comment_prefix         = "${var.comment_prefix}"
  cloudfront_price_class = "${var.cloudfront_price_class}"
  viewer_https_only      = "${var.viewer_https_only}"
  cache_ttl_override     = "${var.cache_ttl_override}"
  default_root_object    = "${var.default_root_object}"
  add_response_headers   = "${var.add_response_headers}"
  basic_auth_username    = "${var.basic_auth_username}"
  basic_auth_password    = "${var.basic_auth_password}"
  basic_auth_realm       = "${var.basic_auth_realm}"
  basic_auth_body        = "${var.basic_auth_body}"
  lambda_logging_enabled = "${var.lambda_logging_enabled}"
  tags                   = "${var.tags}"
}
