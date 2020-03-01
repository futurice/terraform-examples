# aws_static_site

This module implements a website for hosting static content.

Main features:

- DNS entries are created automatically
- S3 bucket is created automatically
- HTTPS enabled by default
- HTTP Strict Transport Security supported
- Direct access to the S3 bucket is prevented

Optional features:

- HTTP Basic Auth
- Plain HTTP instead of HTTPS
- Cache TTL overrides
- Custom response headers sent to clients
- Creating the S3 bucket outside of this module and passing it in via variable

Resources used:

- Route53 for DNS entries
- ACM for SSL certificates
- CloudFront for proxying requests
- Lambda@Edge for transforming requests
- IAM for permissions

## About CloudFront operations

This module manages CloudFront distributions, and these operations are generally very slow. Your `terraform apply` may take anywhere **from 10 minutes up to 45 minutes** to complete. Be patient: if they start successfully, they almost always finish successfully, it just takes a while.

Additionally, this module uses Lambda@Edge functions with CloudFront. Because Lambda@Edge functions are replicated, [they can't be deleted immediately](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html). This means a `terraform destroy` won't successfully remove all resources on its first run. It should complete successfully when running it again after a few hours, however.

## Example 1: Simple static site

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up, and a DNS zone for `example.com` configured on Route 53:

```tf
# Lambda@Edge and ACM, when used with CloudFront, need to be used in the US East region.
# Thus, we need a separate AWS provider for that region, which can be used with an alias.
# Make sure you customize this block to match your regular AWS provider configuration.
# https://www.terraform.io/docs/configuration/providers.html#multiple-provider-instances
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "my_site" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_static_site#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v11.0"

  site_domain = "hello.example.com"
}

resource "aws_s3_bucket_object" "my_index" {
  bucket       = "${module.my_site.bucket_name}"
  key          = "index.html"
  content      = "<pre>Hello World!</pre>"
  content_type = "text/html; charset=utf-8"
}

output "bucket_name" {
  description = "The name of the S3 bucket that's used for hosting the content"
  value       = "${module.my_site.bucket_name}"
}
```

After `terraform apply` (which may take a **very** long time), you should be able to visit `hello.example.com`, be redirected to HTTPS, and be greeted by the above `Hello World!` message.

You may (and probably will) want to upload more files into the bucket outside of Terraform. Using the official [AWS CLI](https://aws.amazon.com/cli/) this could look like:

```bash
aws s3 cp --cache-control=no-store,must-revalidate image.jpg "s3://$(terraform output bucket_name)/"
```

After this, `image.jpg` will be available at `https://hello.example.com/image.jpg`.

## Example 2: Basic Authentication

This module supports password-protecting your site with HTTP Basic Authentication, via a Lambda@Edge function.

Update the `my_site` module in Example 1 as follows:

```tf
module "my_site" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_static_site#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v11.0"

  site_domain = "hello.example.com"

  basic_auth_username = "admin"
  basic_auth_password = "secret"
}
```

After `terraform apply` (which may take a **very** long time), visiting `hello.example.com` should pop out the browser's authentication dialog, and not let you proceed without the above credentials.

## Example 3: Custom response headers

This module supports injecting custom headers into CloudFront responses, via a Lambda@Edge function.

By default, the function only adds `Strict-Transport-Security` headers (as it [significantly improves security](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security#An_example_scenario) with HTTPS), but you may need other customization.

For [additional security hardening of your static site](https://aws.amazon.com/blogs/networking-and-content-delivery/adding-http-security-headers-using-lambdaedge-and-amazon-cloudfront/), update the `my_site` module in Example 1 as follows:

```tf
module "my_site" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_static_site#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v11.0"

  site_domain = "hello.example.com"

  add_response_headers = {
    "Strict-Transport-Security" = "max-age=63072000; includeSubdomains; preload"
    "Content-Security-Policy"   = "default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"
    "X-Content-Type-Options"    = "nosniff"
    "X-Frame-Options"           = "DENY"
    "X-XSS-Protection"          = "1; mode=block"
    "Referrer-Policy"           = "same-origin"
  }
}
```

After `terraform apply` (which may take a **very** long time), visiting `hello.example.com` should give you these extra headers.

It's also possible to override existing headers. For example:

```tf
module "my_site" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_static_site#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v11.0"

  site_domain = "hello.example.com"

  add_response_headers = {
    "Server" = "My Secret Origin Server"
  }
}
```

After `terraform apply`, checking with `curl --silent -I https://hello.example.com | grep Server` should give you `My Secret Origin Server` instead of the default `AmazonS3`.

## Example 4: Using your own bucket

If you already have an S3 bucket that you want to use, you can provide e.g. `bucket_override_name = "my-existing-s3-bucket"` as a variable for this module.

When `bucket_override_name` is provided, an S3 bucket is not automatically created for you. Note that you're then also responsible for setting up a bucket policy allowing CloudFront access to the bucket contents.

## How CloudFront caching works

It's important to understand how CloudFront caches the files it proxies from S3. Because this module is built on the `aws_reverse_proxy` module, [everything its documentation says about CloudFront caching](../aws_reverse_proxy#how-cloudfront-caching-works) is relevant here, too.

### Specifying cache lifetimes on S3

It's a good idea to specify cache lifetimes for files individually, as they are uploaded.

For example, to upload a file so that **it's never cached by CloudFront**:

```bash
aws s3 cp --cache-control=no-store,must-revalidate index.html "s3://$(terraform output bucket_name)/"
```

Alternatively, to upload a file so that **CloudFront can cache it forever**:

```bash
aws s3 cp --cache-control=max-age=31536000 static/image-v123.jpg "s3://$(terraform output bucket_name)/"
```

Learn more about [effective caching strategies on CloudFront](../aws_reverse_proxy#specifying-cache-lifetimes-on-the-origin).

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| add_response_headers | Map of HTTP headers (if any) to add to outgoing responses before sending them to clients | map | `<map>` | no |
| basic_auth_body | When using HTTP Basic Auth, and authentication has failed, this will be displayed by the browser as the page content | string | `"Unauthorized"` | no |
| basic_auth_password | When non-empty, require this password with HTTP Basic Auth | string | `""` | no |
| basic_auth_realm | When using HTTP Basic Auth, this will be displayed by the browser in the auth prompt | string | `"Authentication Required"` | no |
| basic_auth_username | When non-empty, require this username with HTTP Basic Auth | string | `""` | no |
| bucket_override_name | When provided, assume a bucket with this name already exists for the site content, instead of creating the bucket automatically (e.g. `"my-bucket"`) | string | `""` | no |
| cache_ttl_override | When >= 0, override the cache behaviour for ALL objects in S3, so that they stay in the CloudFront cache for this amount of seconds | string | `"-1"` | no |
| cloudfront_price_class | CloudFront price class to use (`100`, `200` or `"All"`, see https://aws.amazon.com/cloudfront/pricing/) | string | `"100"` | no |
| comment_prefix | This will be included in comments for resources that are created | string | `"Static site: "` | no |
| default_root_object | The object to return when the root URL is requested | string | `"index.html"` | no |
| lambda_logging_enabled | When true, writes information about incoming requests to the Lambda function's CloudWatch group | string | `"false"` | no |
| name_prefix | Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed, for S3 bucket name compatibility) | string | `"aws-static-site---"` | no |
| site_domain | Domain on which the static site will be made available (e.g. `"www.example.com"`) | string | n/a | yes |
| tags | AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/ | map | `<map>` | no |
| viewer_https_only | Set this to `false` if you need to support insecure HTTP access for clients, in addition to HTTPS | string | `"true"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_domain_name | Full S3 domain name for the bucket used for hosting the content (e.g. `"aws-static-site---hello-example-com.s3-website.eu-central-1.amazonaws.com"`) |
| bucket_name | The name of the S3 bucket that's used for hosting the content (either auto-generated or externally provided) |
| cloudfront_id | The ID of the CloudFront distribution that's used for hosting the content |
| site_domain | Domain on which the static site will be made available |
<!-- terraform-docs:end -->
