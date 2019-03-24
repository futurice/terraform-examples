# aws_static_site

This module creates:

- An [S3](https://aws.amazon.com/s3/) bucket for hosting your static site
- DNS records on [Route 53](https://aws.amazon.com/route53/)
- A [CloudFront](https://aws.amazon.com/cloudfront/) distribution for SSL termination
- An SSL certificate for the distribution from [ACM](https://aws.amazon.com/certificate-manager/)

Optionally, you can create the S3 bucket outside of this module, and just pass it in as an override.

## How CloudFront caching works

It's important to understand that CloudFront, by default, **respects cache headers given by the origin**, in this case S3.

### Default cache behaviour

Consider the simplest possible configuration below:

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

module "my_site" {
  # Check for updates at: https://github.com/futurice/terraform-utils/compare/v4.1...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v4.1"

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

After applying for the first time, any changes you make to the file on S3 **will be reflected immediately** on the CloudFront distribution. This is because we didn't specify any `Cache-Control` headers for the S3 object, and the `aws_static_site` module will **by default** not cache such objects at all. This is a sensible default, because the AWS default TTL for CloudFront is 24 hours, and for an origin that doesn't explicitly send `Cache-Control` headers, it's rarely the desired behaviour: your site will be serving stale content for up to 24 hours. Users will be sad, and engineers will be yelled at.

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
