resource "aws_s3_bucket" "this" {
  bucket = "${local.prefix_with_domain}"

  # https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl
  acl = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"

    # Note that we don't want to use the simpler 'redirect_all_requests_to' option, as it will insist on trailing slashes (https://stackoverflow.com/q/50763437)
    # https://docs.aws.amazon.com/AmazonS3/latest/dev/how-to-page-redirect.html#advanced-conditional-redirects
    routing_rules = <<EOF
[
  {
    "Redirect": {
      "Protocol": "${local.url_protocol}",
      "HostName": "${local.url_hostname}",
      "ReplaceKeyWith": "${local.url_path}",
      "HttpRedirectCode": "${var.redirect_code}"
    }
  }
]
EOF
  }
}
