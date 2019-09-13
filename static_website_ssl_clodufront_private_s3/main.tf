## ACM Certificate
data "aws_route53_zone" "this" {
  name = replace(var.site_domain, "/.*\\b(\\w+\\.\\w+)\\.?$/", "$1") # gets domain from subdomain e.g. "foo.example.com" => "example.com"
}

module "acm" {
  source      = "terraform-aws-modules/acm/aws"
  version     = "~> v2.0"
  domain_name = var.site_domain
  zone_id     = data.aws_route53_zone.this.zone_id
  tags        = var.tags

  providers = {
    aws = "aws.us_east_1" # cloudfront needs acm certificate to be from "us-east-1" region
  }
}

## S3
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.this.id

  block_public_acls   = true
  block_public_policy = true
}

data "aws_iam_policy_document" "s3_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.this.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_policy_document.json
}

## Cloudfront

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "Origin Access Identity used to access S3 for ${var.site_domain}"
}


resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.site_domain
  default_root_object = var.default_root_object

  aliases = [var.site_domain]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
  }
  price_class = var.cf_price_class

  tags = var.tags

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  viewer_certificate {
    acm_certificate_arn      = module.acm.this_acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  # By default, cloudfront caches error for five minutes. There can be situation when a developer has accidentally broken the website and you would not want to wait for five minutes for the error response to be cached.
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/CustomErrorDocSupport.html
  custom_error_response {
    error_code            = 400
    error_caching_min_ttl = var.error_ttl
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = var.error_ttl
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = var.error_ttl
  }

  custom_error_response {
    error_code            = 405
    error_caching_min_ttl = var.error_ttl
  }

}



## Route53
# Add an IPv4 DNS record pointing to the CloudFront distribution
resource "aws_route53_record" "ipv4" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.site_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

# Add an IPv6 DNS record pointing to the CloudFront distribution
resource "aws_route53_record" "ipv6" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.site_domain
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
