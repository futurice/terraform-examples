# aws_mailgun_domain

Uses the [Terraform Mailgun provider](https://www.terraform.io/docs/providers/mailgun/index.html) to set up and verify a domain, so you can use [Mailgun](https://www.mailgun.com/) for sending email from it.

## Example

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up, and a DNS zone for `example.com` configured on Route 53:

```tf
variable "mailgun_api_key" {
  description = "Your Mailgun API key"
}

variable "demo_email_address" {
  description = "Enter your email (e.g. me@gmail.com), so you'll get a copy-pasteable curl command for testing the API immediately"
}

# Configure the Mailgun provider
# https://www.terraform.io/docs/providers/mailgun/index.html
provider "mailgun" {
  version = "~> 0.1"
  api_key = "${var.mailgun_api_key}"
}

module "my_mailgun_domain" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_mailgun_domain#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_mailgun_domain?ref=v11.0"

  mail_domain   = "example.com"
  smtp_password = "SECRET SECRET SECRET"
}

output "demo_curl_command" {
  value = "curl -s --user 'api:${var.mailgun_api_key}' ${module.my_mailgun_domain.api_base_url}messages -F from='Demo <demo@${module.my_mailgun_domain.mail_domain}>' -F to='${var.demo_email_address}' -F subject='Hello' -F text='Testing, testing...'"
}
```

Note that due to [a bug in Terraform](https://github.com/hashicorp/terraform/issues/12570), at the time of writing, you need to apply in two parts:

```bash
$ terraform apply -target module.my_mailgun_domain.mailgun_domain.this
...
$ terraform apply
...
```

After the `terraform apply`, you either need to wait a bit, or if you're impatient, log into your Mailgun control panel and manually trigger the DNS verification. If you're too quick, running the command given by `demo_curl_command` will give you something like:

```json
{
  "message": "The domain is unverified and requires DNS configuration. Log in to your control panel to view required DNS records."
}
```

After Mailgun is happy with your DNS records, however, you should get something like:

```json
{
  "id": "<20190401125249.1.XXXYYYZZZ@example.com>",
  "message": "Queued. Thank you."
}
```

...and you should receive the test email shortly.

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| mail_domain | Domain which you want to use for sending/receiving email (e.g. `"example.com"`) | string | n/a | yes |
| smtp_password | Password that Mailgun will require for sending out SMPT mail via this domain | string | n/a | yes |
| spam_action | See https://www.terraform.io/docs/providers/mailgun/r/domain.html#spam_action | string | `"disabled"` | no |
| tags | AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/ | map | `<map>` | no |
| wildcard | See https://www.terraform.io/docs/providers/mailgun/r/domain.html#wildcard | string | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| api_base_url | Base URL of the Mailgun API for your domain |
| mail_domain | Domain which you want to use for sending/receiving email (e.g. `"example.com"`) |
<!-- terraform-docs:end -->
