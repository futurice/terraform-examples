# Create the CloudFront distribution through which the site contents will be served
# https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "${var.default_root_object}"
  aliases             = ["${var.site_domain}"]
  price_class         = "PriceClass_${var.cloudfront_price_class}"
  comment             = "${var.comment_prefix}${var.site_domain}"
  tags                = "${var.tags}"

  # Define the "upstream" for the CloudFront distribution
  origin {
    domain_name = "${local.url_hostname}"
    origin_id   = "default"
    origin_path = "${local.url_path == "" ? "" : "/${local.url_path}"}"

    custom_origin_config {
      http_port              = "${var.origin_custom_port > 0 ? "${var.origin_custom_port}" : 80}"
      https_port             = "${var.origin_custom_port > 0 ? "${var.origin_custom_port}" : 443}"
      origin_protocol_policy = "${local.url_protocol}-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    custom_header {
      name  = "${var.origin_custom_header_name}"
      value = "${var.origin_custom_header_value}"
    }
  }

  # Define how to serve the content to clients
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "default"
    viewer_protocol_policy = "${var.viewer_https_only ? "redirect-to-https" : "allow-all"}"
    compress               = true

    min_ttl     = "${var.cache_ttl_override >= 0 ? var.cache_ttl_override : 0}"     # for reference: AWS default is 0
    default_ttl = "${var.cache_ttl_override >= 0 ? var.cache_ttl_override : 0}"     # for reference: AWS default is 86400 (i.e. one day)
    max_ttl     = "${var.cache_ttl_override >= 0 ? var.cache_ttl_override : 86400}" # i.e. 1 day; for reference: AWS default is 31536000 (i.e. one year)

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    # Note: This will make the Lambda undeletable, as long as this distribution/association exists
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html
    lambda_function_association {
      event_type = "viewer-request"                                                                          # one of [ viewer-request, origin-request, viewer-response, origin-response ]
      lambda_arn = "${aws_lambda_function.viewer_request.arn}:${aws_lambda_function.viewer_request.version}"
    }

    # Note: This will make the Lambda undeletable, as long as this distribution/association exists
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html
    lambda_function_association {
      event_type = "viewer-response"                                                                           # one of [ viewer-request, origin-request, viewer-response, origin-response ]
      lambda_arn = "${aws_lambda_function.viewer_response.arn}:${aws_lambda_function.viewer_response.version}"
    }
  }

  # This (and other custom_error_response's below) are important, because otherwise CloudFront defaults to caching errors for 5 minutes.
  # This means that if you accidentally deploy broken code, your users will be stuck seeing the error regardless of how quickly you roll back.
  # Unless a "cache_ttl_override" is provided, we never cache errors.
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/custom-error-pages-expiration.html
  custom_error_response {
    error_code            = 400                  # == "Bad Request"
    error_caching_min_ttl = "${local.error_ttl}"
  }

  custom_error_response {
    error_code            = 403                  # == "Forbidden"
    error_caching_min_ttl = "${local.error_ttl}"
  }

  custom_error_response {
    error_code            = 404                  # == "Not Found"
    error_caching_min_ttl = "${local.error_ttl}"
  }

  custom_error_response {
    error_code            = 405                  # == "Method Not Allowed"
    error_caching_min_ttl = "${local.error_ttl}"
  }

  custom_error_response {
    error_code            = 414                  # == "Request-URI Too Long"
    error_caching_min_ttl = "${local.error_ttl}"
  }

  custom_error_response {
    error_code            = 416                  # == "Requested Range Not Satisfiable"
    error_caching_min_ttl = "${local.error_ttl}"
  }

  custom_error_response {
    error_code            = 500                  # == "Internal Server Error"
    error_caching_min_ttl = "${local.error_ttl}"
  }

  custom_error_response {
    error_code            = 501                  # == "Not Implemented"
    error_caching_min_ttl = "${local.error_ttl}"
  }

  custom_error_response {
    error_code            = 502                  # == "Bad Gateway"
    error_caching_min_ttl = "${local.error_ttl}"
  }

  custom_error_response {
    error_code            = 503                  # == "Service Unavailable"
    error_caching_min_ttl = "${local.error_ttl}"
  }

  custom_error_response {
    error_code            = 504                  # == "Gateway Timeout"
    error_caching_min_ttl = "${local.error_ttl}"
  }

  # This is mandatory in Terraform :shrug:
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Attach our auto-generated ACM certificate to the distribution
  # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#viewer-certificate-arguments
  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate_validation.this.certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}
