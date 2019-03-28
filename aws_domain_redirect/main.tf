module "aws_static_site" {
  # Check for updates at: https://github.com/futurice/terraform-utils/compare/v5.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v5.0"

  site_domain                 = "${var.redirect_domain}"
  name_prefix                 = "${var.name_prefix}"
  distribution_comment_prefix = "${var.distribution_comment_prefix}"
  bucket_override_name        = "-"                                  # providing this ensures an S3 bucket isn't unnecessarily created, even if this isn't a valid bucket name
  price_class                 = "${var.redirect_price_class}"
  lambda_logging_enabled      = "${var.lambda_logging_enabled}"

  add_response_headers = {
    "Strict-Transport-Security" = "${var.redirect_with_hsts ? "max-age=31557600; preload" : ""}"
    "Location"                  = "${var.redirect_url}"
  }

  override_response_status             = "${var.redirect_permanently ? "301" : "302"}"
  override_response_status_description = "${var.redirect_permanently ? "Moved Permanently" : "Found"}"

  override_response_body = <<EOF
  <!doctype html>
  <html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Redirecting</title>
  </head>
  <body>
    <pre>Redirecting to: <a href="${var.redirect_url}">${var.redirect_url}</a></pre>
  </body>
  EOF
}
