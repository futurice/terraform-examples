# aws_mailgun_domain

Uses the [Terraform Mailgun provider](https://www.terraform.io/docs/providers/mailgun/index.html) to set up and verify a domain, so you can use [Mailgun](https://www.mailgun.com/) for sending email from it.

## Example

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up, and a DNS zone for `example.com` configured on Route 53:

```tf
module "my_mailgun_domain" {
  # Check for updates at: https://github.com/futurice/terraform-utils/compare/v6.1...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_mailgun_domain?ref=v6.1"

  api_key               = "SECRET SECRET SECRET"
  mailgun_domain        = "example.com"
  mailgun_smtp_password = "ANOTHER SECRET SECRET"
}

variable "demo_email_address" {
  description = "You can enter your email (e.g. me@gmail.com), if you want a copy-pasteable curl command for testing the API immediately"
}

output "demo_curl_command" {
  value = "curl -s --user '${module.my_domain.api_credentials}' ${module.my_domain.api_base_url}messages -F from='Demo <demo@${module.my_domain.mail_domain}>' -F to='${var.demo_email_address}' -F subject='Hello' -F text='Testing, testing...'"
}
```

After `terraform apply`, you either need to wait a bit, or if you're impatient, log into your Mailgun control panel and manually trigger the DNS verification.

After Mailgun is happy with your DNS records, go ahead and run the command given by `demo_curl_command`, and you should receive the email shortly.

<!-- terraform-docs:begin -->
<!-- terraform-docs:end -->
