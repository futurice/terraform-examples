# https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""
  aliases             = ["${var.redirect_domain}"]
  price_class         = "PriceClass_${var.redirect_price_class}"
  comment             = "Redirect for domain: ${var.redirect_domain}"

  # Define a default origin; note that this domain won't ever be contacted, because our Lambda function will intercept any requests before that.
  # CloudFront requires a default origin to be provided, however, hence this placeholder.
  origin {
    domain_name = "example.org"
    origin_id   = "aws_domain_redirect"
    origin_path = ""

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  # Define how to serve the content to clients
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "aws_domain_redirect"
    viewer_protocol_policy = "redirect-to-https"   # only allow requests over HTTPS
    compress               = true

    min_ttl     = 0                           # default is 0
    default_ttl = "${var.redirect_cache_ttl}" # default is 86400 (i.e. one day)
    max_ttl     = "${var.redirect_cache_ttl}" # default is 31536000 (i.e. one year)

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    # Note: This will make the Lambda undeletable, as long as this distribution/association exists
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html
    lambda_function_association {
      event_type = "viewer-request"                                                      # one of [ viewer-request, origin-request, viewer-response, origin-response ]
      lambda_arn = "${aws_lambda_function.this.arn}:${aws_lambda_function.this.version}"
    }
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
