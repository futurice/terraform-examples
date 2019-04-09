# aws_static_site

This module implements a website for hosting static content on AWS, by creating:

- An [S3](https://aws.amazon.com/s3/) bucket for hosting your static site
- DNS records on [Route 53](https://aws.amazon.com/route53/)
- A [CloudFront](https://aws.amazon.com/cloudfront/) distribution for SSL termination
- An SSL certificate for the distribution from [ACM](https://aws.amazon.com/certificate-manager/)
- A [Lambda@Edge](https://docs.aws.amazon.com/lambda/latest/dg/lambda-edge.html) function for custom response headers, and Basic Auth support

Optionally, you can create the S3 bucket outside of this module, and just pass it in as an override.

## Example 1: Simple static site

**Important:** CloudFront operations are generally very slow. Your `terraform apply` may take anywhere **from 10 minutes up to 45 minutes** to complete. Additionally, because Lambda@Edge functions are replicated, [they can't be deleted immediately](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html). This means a `terraform destroy` won't successfully remove all resources on its first run. It should complete successfully when running it again after a few hours, however.

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up, and a DNS zone for `example.com` configured on Route 53:

```tf
# Several AWS services (such as ACM & Lambda@Edge) are presently only available in the US East region.
# To be able to use them, we need a separate AWS provider for that region, which can be used with an alias.
# Make sure you customize this block to match your regular AWS provider configuration.
# https://www.terraform.io/docs/configuration/providers.html#multiple-provider-instances
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "my_site" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_static_site#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v9.3...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v9.3"

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

The `aws_static_site` module supports password-protecting your site with HTTP Basic Authentication, via a Lambda@Edge function.

Update the `my_site` module in Example 1 as follows:

```tf
module "my_site" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_static_site#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v9.3...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v9.3"

  site_domain = "hello.example.com"

  basic_auth_username = "admin"
  basic_auth_password = "secret"
}
```

After `terraform apply` (which may take a **very** long time), visiting `hello.example.com` should pop out the browser's authentication dialog, and not let you proceed without the above credentials.

## Example 3: Custom response headers

The `aws_static_site` module supports injecting custom headers into CloudFront responses, via a Lambda@Edge function.

By default, the function only adds `Strict-Transport-Security` headers (as it [significantly improves security](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security#An_example_scenario) with HTTPS), but you may need other customization.

For [additional security hardening of your static site](https://aws.amazon.com/blogs/networking-and-content-delivery/adding-http-security-headers-using-lambdaedge-and-amazon-cloudfront/), update the `my_site` module in Example 1 as follows:

```tf
module "my_site" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_static_site#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v9.3...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v9.3"

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
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v9.3...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v9.3"

  site_domain = "hello.example.com"

  add_response_headers = {
    "Server" = "My Secret Origin Server"
  }
}
```

After `terraform apply`, checking with `curl --silent -I https://hello.example.com | grep Server` should give you `My Secret Origin Server` instead of the default `AmazonS3`.

## Example 4: Using your own bucket

If you already have an S3 bucket that you want to use, you can provide e.g. `bucket_override_name = "my-existing-s3-bucket"` as a variable for the `aws_static_site` module.

When `bucket_override_name` is provided, an S3 bucket is not automatically created for you. Note that you're then also responsible for setting up a bucket policy allowing CloudFront access to the bucket contents.

## Example 5: Overriding the response completely

In very specific circumstances, you may want to always return a specific response, and not forward any requests to S3.

Update the `my_site` module in Example 1 as follows:

```tf
module "my_site" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_static_site#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v9.3...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v9.3"

  site_domain = "hello.example.com"

  bucket_override_name = "-" # providing this ensures an S3 bucket isn't unnecessarily created, even if this isn't a valid bucket name

  override_response_status             = "500"
  override_response_status_description = "Internal Server Error"
  override_response_body               = "<pre>The server made a boo-boo :(</pre>"
}
```

## How CloudFront caching works

It's important to understand that CloudFront, by default, **respects cache headers given by the origin**, in this case S3.

### Default cache behaviour

Consider the configuration in Example 1. After applying for the first time, any changes you make to the file on S3 **will be reflected immediately** on the CloudFront distribution. This is because we didn't specify any `Cache-Control` headers for the S3 object, and the `aws_static_site` module will **by default** not cache such objects at all. This is a sensible default, because the AWS default TTL for CloudFront is 24 hours, and for an origin that doesn't explicitly send `Cache-Control` headers, it's rarely the desired behaviour: your site will be serving stale content for up to 24 hours. Users will be sad, and engineers will be yelled at.

Having immediate updates on CloudFront is convenient, but the downside is that every request for every file will be forwarded to S3, to make sure the CloudFront cache still has the latest version. This will increase request latency for users, and infrastructure costs for you.

### Specifying cache lifetimes on S3

A better way to specify cache lifetimes for objects is to do so individually, per object, as they are uploaded. Various tools exist for uploading things to S3. Using the official [AWS CLI](https://aws.amazon.com/cli/) this could look like:

```bash
aws s3 cp --cache-control=no-store,must-revalidate index.html "s3://$(terraform output bucket_name)/"
aws s3 cp --cache-control=max-age=31536000 static/image-v123.jpg "s3://$(terraform output bucket_name)/"
```

This will upload `index.html` so that CloudFront will **never** serve its content to a user, without first checking that it's not been updated on S3. However, `image-v123.jpg` will be uploaded with cache headers that allow CloudFront to keep its copy for that object **forever** (well, technically 1 year, which is the maximum recommended value for `max-age`; in practice CloudFront will evict it before that for other reasons).

The above is a good middle ground, where you want immediate updates for your HTML documents (e.g. `index.html`), but static assets (e.g. `image-v123.jpg`) can be cached for much longer. This means that for the HTML document itself, you won't get any latency benefits from CloudFront, but as the browsers starts downloading the various linked static assets, they can be served directly from the CloudFront edge location, which should be much closer to the user, geographically. When you need to update the linked image, instead of updating `image-v123.jpg`, you should instead upload `image-v124.jpg`, and update any links in `index.html` to point to the new version. This ensures that:

1. Users will see the new document (including its updated images) immediately
1. Users won't see an inconsistent version of the document, where the document content is updated, but it's still showing the old images

### Overriding cache lifetimes on CloudFront

If the tool you're using for S3 uploads doesn't support setting cache headers, or you're just feeling lazy, the `aws_static_site` module supports overriding cache behaviour on CloudFront, effectively ignoring anything S3 says about caching objects.

That is, if you specify `cache_ttl_override = 0` for your site, every object will always be fetched from S3, for every request. Importantly, though, this won't invalidate objects that *are already* in the CloudFront cache with a longer TTL. If you have an object that's "stuck" in your cache and you can't shake it, the CloudFront feature you're looking for is [file invalidation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html).

Conversely, if you specify `cache_ttl_override = 300`, every object will stay in CloudFront for 5 minutes, regardless of its cache headers. This can be a good performance boost for your site, since only 1 request per file per 5 minutes will need to go all the way to S3, and all the others can be served immediately from the CloudFront edge location. Keep in mind the aforementioned warning about "inconsistent versions", however: each object has their own TTL counter, so `index.html` and `image.jpg` may update at different times in the cache, even if you upload an update to S3 at the same time.

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| add_response_headers | Map of HTTP headers (if any) to add to outgoing responses before sending them to clients | map | `<map>` | no |
| aws_tags | AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/ | map | `<map>` | no |
| basic_auth_body | When using HTTP Basic Auth, and authentication has failed, this will be displayed by the browser as the page content | string | `"Unauthorized"` | no |
| basic_auth_password | When non-empty, require this password with HTTP Basic Auth | string | `""` | no |
| basic_auth_realm | When using HTTP Basic Auth, this will be displayed by the browser in the auth prompt | string | `"Authentication Required"` | no |
| basic_auth_username | When non-empty, require this username with HTTP Basic Auth | string | `""` | no |
| bucket_override_name | When provided, assume a bucket with this name already exists for the site content, instead of creating the bucket automatically (e.g. `"my-bucket"`) | string | `""` | no |
| cache_ttl_override | When >= 0, override the cache behaviour for ALL objects in S3, so that they stay in the CloudFront cache for this amount of seconds | string | `"-1"` | no |
| comment_prefix | This will be included in comments for resources that are created | string | `"Static site: "` | no |
| default_root_object | The object to return when the root URL is requested | string | `"index.html"` | no |
| https_only | Set this to `false` if you want to support insecure HTTP access, in addition to HTTPS | string | `"true"` | no |
| lambda_logging_enabled | When true, writes information about incoming requests to the Lambda function's CloudWatch group | string | `"false"` | no |
| name_prefix | Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed, for S3 bucket name compatibility) | string | `"aws-static-site---"` | no |
| override_response_body | Same as `override_response_status` | string | `""` | no |
| override_response_status | When this and the other `override_response_*` variables are non-empty, skip sending the request to the origin altogether, and instead respond as instructed here | string | `""` | no |
| override_response_status_description | Same as `override_response_status` | string | `""` | no |
| price_class | CloudFront price class to use (`100`, `200` or `"All"`, see https://aws.amazon.com/cloudfront/pricing/) | string | `"100"` | no |
| site_domain | Domain on which the static site will be made available (e.g. `"www.example.com"`) | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bucket_domain_name | Full S3 domain name for the bucket used for hosting the content (e.g. `"aws-static-site---hello-example-com.s3-website.eu-central-1.amazonaws.com"`) |
| bucket_name | The name of the S3 bucket that's used for hosting the content (either auto-generated or externally provided) |
| cloudfront_id | The ID of the CloudFront distribution that's used for hosting the content |
| site_domain | Domain on which the static site will be made available |
<!-- terraform-docs:end -->
