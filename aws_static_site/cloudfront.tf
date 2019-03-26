# Create the CloudFront distribution through which the S3 bucket contents will be served
# https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "${var.default_root_object}"
  aliases             = ["${var.site_domain}"]
  price_class         = "PriceClass_${var.price_class}"
  comment             = "Static site: ${var.site_domain}"

  # Define the S3 bucket as the "upstream" for the CloudFront distribution
  origin {
    domain_name = "${local.bucket_domain_name}"
    origin_id   = "aws_static_site"
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
    target_origin_id       = "aws_static_site"
    viewer_protocol_policy = "redirect-to-https" # only allow requests over HTTPS
    compress               = true

    min_ttl     = "${var.cache_ttl_override >= 0 ? var.cache_ttl_override : 0}"     # for reference: AWS default is 0
    default_ttl = "${var.cache_ttl_override >= 0 ? var.cache_ttl_override : 0}"     # for reference: AWS default is 86400 (i.e. one day)
    max_ttl     = "${var.cache_ttl_override >= 0 ? var.cache_ttl_override : 86400}" # i.e. 1 day; for reference: AWS default is 31536000 (i.e. one year)

    forwarded_values {
      query_string = false # since we're forwarding to S3, no need to forward anything

      cookies {
        forward = "none" # ^ ditto
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
