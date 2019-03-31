# aws_mailgun_domain

Uses the [Terraform Mailgun provider](https://www.terraform.io/docs/providers/mailgun/index.html) to set up and verify a domain, so you can use [Mailgun](https://www.mailgun.com/) for sending email from it.

## Example

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up, and a DNS zone for `example.com` configured on Route 53:

```tf
module "my_mailgun_domain" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_mailgun_domain#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v7.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_mailgun_domain?ref=v7.0"

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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| api_key | Your secret Mailgun API key | string | n/a | yes |
| mail_domain | Domain which you want to use for sending/receiving email (e.g. `"example.com"`) | string | n/a | yes |
| smtp_password | Password that Mailgun will require for sending out SMPT mail via this domain | string | n/a | yes |
| spam_action | See https://www.terraform.io/docs/providers/mailgun/r/domain.html#spam_action | string | `"disabled"` | no |
| wildcard | See https://www.terraform.io/docs/providers/mailgun/r/domain.html#wildcard | string | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| api_base_url | Base URL of the Mailgun API for your domain |
| api_credentials | HTTP Basic Auth credentials for acessing the Mailgun API |
| mail_domain | Domain which you want to use for sending/receiving email (e.g. `"example.com"`) |
<!-- terraform-docs:end -->
