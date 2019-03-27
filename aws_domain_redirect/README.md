# aws_domain_redirect

Creates the necessary resources on AWS to implement an HTTP redirect from a domain (e.g. `redir.example.com`) to a given URL (e.g. `https://www.futurice.com/careers/women-who-code-helsinki`). Useful for creating human-friendly shortcuts for deeper links into a site, or for dynamic links (e.g. `download.example.com` always pointing to your latest release).

Implementing this on AWS actually requires quite a few resources:

- DNS records on [Route 53](https://aws.amazon.com/route53/)
- A [CloudFront](https://aws.amazon.com/cloudfront/) distribution for SSL termination
- An SSL certificate for the distribution from [ACM](https://aws.amazon.com/certificate-manager/)
- A [Lambda@Edge](https://docs.aws.amazon.com/lambda/latest/dg/lambda-edge.html) function that implements the redirect itself

Luckily, this module encapsulates this configuration quite neatly.

The Lambda function also adds [HSTS](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) headers to prevent [man-in-the-middle attacks](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security#An_example_scenario).

## Example

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up, and a DNS zone for `example.com` configured on Route 53:

```tf
# Several AWS services (such as ACM & Lambda@Edge) are presently only available in the US East region.
# To be able to use them, we need a separate AWS provider for that region, which can be used with an alias.
# https://docs.aws.amazon.com/acm/latest/userguide/acm-services.html
# https://www.terraform.io/docs/configuration/providers.html#multiple-provider-instances
provider "aws" {
  alias                   = "us_east_1"
  shared_credentials_file = "./aws.key" # make sure you customize this to match your regular AWS provider config
  region                  = "us-east-1"
}

module "my_redirect" {
  # Check for updates at: https://github.com/futurice/terraform-utils/compare/v5.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_domain_redirect?ref=v5.0"

  redirect_domain = "go.example.com"
  redirect_url    = "https://www.futurice.com/careers/"
}
```

Applying this **will take a very long time**, because both ACM and especially CloudFront are quite slow to update. After that, both `http://go.example.com` and `https://go.example.com` should redirect clients to `https://www.futurice.com/careers/`.
