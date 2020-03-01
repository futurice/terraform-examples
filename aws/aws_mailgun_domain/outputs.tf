output "mail_domain" {
  value       = "${var.mail_domain}"
  description = "Domain which you want to use for sending/receiving email (e.g. `\"example.com\"`)"
}

output "api_base_url" {
  value       = "https://api.mailgun.net/v3/${var.mail_domain}/"
  description = "Base URL of the Mailgun API for your domain"
}
