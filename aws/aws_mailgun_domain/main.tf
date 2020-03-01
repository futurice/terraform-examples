# Create a new Mailgun domain
resource "mailgun_domain" "this" {
  name          = "${var.mail_domain}"
  spam_action   = "${var.spam_action}"
  wildcard      = "${var.wildcard}"
  smtp_password = "${var.smtp_password}"
}

# DNS records for domain setup & verification are below
# See https://app.mailgun.com/app/domains/<your-domain>/verify for these instructions

resource "aws_route53_record" "sending" {
  count = "${length(mailgun_domain.this.sending_records)}"

  zone_id = "${data.aws_route53_zone.this.zone_id}"
  name    = "${lookup(mailgun_domain.this.sending_records[count.index], "name")}"
  type    = "${lookup(mailgun_domain.this.sending_records[count.index], "record_type")}"
  ttl     = 300

  records = [
    "${lookup(mailgun_domain.this.sending_records[count.index], "value")}",
  ]
}

resource "aws_route53_record" "receiving" {
  zone_id = "${data.aws_route53_zone.this.zone_id}"
  name    = "${var.mail_domain}"
  type    = "${lookup(mailgun_domain.this.receiving_records[0], "record_type")}"
  ttl     = 300

  records = [
    "${lookup(mailgun_domain.this.receiving_records[0], "priority")} ${lookup(mailgun_domain.this.receiving_records[0], "value")}",
    "${lookup(mailgun_domain.this.receiving_records[1], "priority")} ${lookup(mailgun_domain.this.receiving_records[1], "value")}",
  ]
}
