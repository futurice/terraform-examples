# Create the CloudFront distribution through which the S3 bucket contents will be served
# https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""
  aliases             = ["${var.redirect_domain}"]
  price_class         = "PriceClass_${var.redirect_price_class}"
  comment             = "Redirect domain: ${var.redirect_domain}"

  # Define the S3 bucket as the "upstream" for the CloudFront distribution
  origin {
    domain_name = "${aws_s3_bucket.this.website_endpoint}"
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
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    min_ttl     = 0                           # default is 0
    default_ttl = "${var.redirect_cache_ttl}" # default is 86400 (i.e. one day)
    max_ttl     = "${var.redirect_cache_ttl}" # default is 31536000 (i.e. one year)

    forwarded_values {
      query_string = false # since we're forwarding to S3, no need to forward anything

      cookies {
        forward = "none"
      }
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

# https://www.terraform.io/docs/providers/aws/r/acm_certificate.html
resource "aws_acm_certificate" "this" {
  provider          = "aws.acm_provider"       # because ACM is only available in the "us-east-1" region
  domain_name       = "${var.redirect_domain}"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.this.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.this.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.this.zone_id}"
  records = ["${aws_acm_certificate.this.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  provider                = "aws.acm_provider"                             # because ACM is only available in the "us-east-1" region
  certificate_arn         = "${aws_acm_certificate.this.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
