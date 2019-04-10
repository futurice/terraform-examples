# Generate a certificate for the domain automatically using ACM
# https://www.terraform.io/docs/providers/aws/r/acm_certificate.html
resource "aws_acm_certificate" "this" {
  provider          = "aws.us_east_1"                                                              # because ACM is only available in the "us-east-1" region
  domain_name       = "${var.site_domain}"
  validation_method = "DNS"                                                                        # the required records are created below
  tags              = "${merge(var.tags, map("Name", "${var.comment_prefix}${var.site_domain}"))}"
}

# Add the DNS records needed by the ACM validation process
resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.this.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.this.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.this.zone_id}"
  records = ["${aws_acm_certificate.this.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

# Request a validation for the cert with ACM
resource "aws_acm_certificate_validation" "this" {
  provider                = "aws.us_east_1"                                # because ACM is only available in the "us-east-1" region
  certificate_arn         = "${aws_acm_certificate.this.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
