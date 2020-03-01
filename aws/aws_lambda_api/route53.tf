# Add an IPv4 DNS record pointing to the API Gateway
resource "aws_route53_record" "ipv4" {
  zone_id = "${data.aws_route53_zone.this.zone_id}"
  name    = "${var.api_domain}"
  type    = "A"

  alias {
    name                   = "${aws_api_gateway_domain_name.this.regional_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.this.regional_zone_id}"
    evaluate_target_health = false
  }
}

# Add an IPv6 DNS record pointing to the API Gateway
resource "aws_route53_record" "ipv6" {
  zone_id = "${data.aws_route53_zone.this.zone_id}"
  name    = "${var.api_domain}"
  type    = "AAAA"

  alias {
    name                   = "${aws_api_gateway_domain_name.this.regional_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.this.regional_zone_id}"
    evaluate_target_health = false
  }
}
