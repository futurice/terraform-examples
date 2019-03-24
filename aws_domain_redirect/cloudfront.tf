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

# https://www.terraform.io/docs/providers/aws/r/acm_certificate.html
resource "aws_acm_certificate" "this" {
  provider          = "aws.us_east_1"          # because ACM is only available in the "us-east-1" region
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
  provider                = "aws.us_east_1"                                # because ACM is only available in the "us-east-1" region
  certificate_arn         = "${aws_acm_certificate.this.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

provider "template" {
  version = "~> 2.1"
}

locals {
  config = {
    redirect_url         = "${var.redirect_url}"
    redirect_permanently = "${var.redirect_permanently ? "1" :""}" # booleans need to be encoded as strings
    redirect_with_hsts   = "${var.redirect_with_hsts ? "1" :""}"   # booleans need to be encoded as strings
  }
}

# Because: error creating CloudFront Distribution: InvalidLambdaFunctionAssociation: The function cannot have environment variables.
data "template_file" "lambda" {
  template = "${file("${path.module}/lambda.tpl.js")}"

  vars = {
    config = "${replace(jsonencode(local.config), "'", "\\'")}" # single quotes need to be escaped, lest we end up with a parse error on the JS side
  }
}

provider "archive" {
  version = "~> 1.2"
}

data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    filename = "lambda.js"
    content  = "${data.template_file.lambda.rendered}"
  }
}

resource "aws_lambda_function" "this" {
  provider         = "aws.us_east_1"                                   # because: error creating CloudFront Distribution: InvalidLambdaFunctionAssociation: The function must be in region 'us-east-1'
  filename         = "${path.module}/lambda.zip"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  function_name    = "${local.prefix_with_domain}"
  role             = "${aws_iam_role.this.arn}"
  description      = "Redirect for domain: ${var.redirect_domain}"
  handler          = "lambda.viewer_request"
  runtime          = "nodejs8.10"
  publish          = true                                              # because: error creating CloudFront Distribution: InvalidLambdaFunctionAssociation: The function ARN must reference a specific function version. (The ARN must end with the version number.)
}

# Allow Lambda@Edge to invoke our functions
resource "aws_iam_role" "this" {
  name = "${local.prefix_with_domain}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Allow writing logs to CloudWatch from our functions
resource "aws_iam_policy" "this" {
  count = "${var.lambda_logging_enabled ? 1 : 0}"
  name  = "${local.prefix_with_domain}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = "${var.lambda_logging_enabled ? 1 : 0}"
  role       = "${aws_iam_role.this.name}"
  policy_arn = "${aws_iam_policy.this.arn}"
}
