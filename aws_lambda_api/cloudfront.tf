# Create the CloudFront distribution through which the function will be exposed
# https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""
  aliases             = ["${var.api_domain}"]
  price_class         = "PriceClass_${var.price_class}"
  comment             = "${var.comment_prefix}${var.api_domain}"

  # Define API Gateway as the "upstream" for the CloudFront distribution
  origin {
    # Sadly, the aws_api_gateway_deployment resource doesn't export this value on its own
    # e.g. "https://abcdefg.execute-api.eu-central-1.amazonaws.com/default" => "abcdefg.execute-api.eu-central-1.amazonaws.com"
    domain_name = "${replace(aws_api_gateway_deployment.this.invoke_url, "/^.*\\/\\/(.*)\\/.*$/", "$1")}"

    origin_id   = "aws_lambda_api"
    origin_path = "/${var.stage_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  # Define how to serve the content to clients
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "aws_lambda_api"
    viewer_protocol_policy = "${var.https_only ? "redirect-to-https" : "allow-all"}"
    compress               = true

    # Since the distribution is just SSL-terminating for API Gateway (with a custom domain), let's not ever cache anything
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  # This (and other custom_error_response's below) are important, because otherwise CloudFront defaults to caching errors for 5 minutes.
  # This means that if you accidentally deploy broken code, your users will be stuck seeing the error regardless of how quickly you roll back.
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/custom-error-pages-expiration.html
  custom_error_response {
    error_code            = 400 # Bad Request
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 403 # Forbidden
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404 # Not Found
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 405 # Method Not Allowed
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 414 # Request-URI Too Long
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 416 # Requested Range Not Satisfiable
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 500 # Internal Server Error
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 501 # Not Implemented
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 502 # Bad Gateway
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 503 # Service Unavailable
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 504 # Gateway Timeout
    error_caching_min_ttl = 0
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
