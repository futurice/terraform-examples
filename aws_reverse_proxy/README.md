# aws_reverse_proxy

This module implements a website that proxies content from another server.

Main features:

- DNS entries are created automatically
- HTTPS enabled by default
- HTTP Strict Transport Security supported

Optional features:

- HTTP Basic Auth
- Plain HTTP instead of HTTPS
- Cache TTL overrides
- Custom response headers sent to clients
- Custom request headers sent to origin server
- Static response status/body override

Resources used:

- Route53 for DNS entries
- ACM for SSL certificates
- CloudFront for proxying requests
- Lambda@Edge for transforming requests
- IAM for permissions

## About CloudFront operations

This module manages CloudFront distributions, and these operations are generally very slow. Your `terraform apply` may take anywhere **from 10 minutes up to 45 minutes** to complete. Be patient: if they start successfully, they almost always finish successfully, it just takes a while.

Additionally, this module uses Lambda@Edge functions with CloudFront. Because Lambda@Edge functions are replicated, [they can't be deleted immediately](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html). This means a `terraform destroy` won't successfully remove all resources on its first run. It should complete successfully when running it again after a few hours, however.

## Examples

Some common use cases for this module are:

- [Static website hosting with S3](../aws_static_site)
- [Redirecting clients from a domain to another URL](../aws_domain_redirect)
- SSL termination in front of a server/load balancer elsewhere on AWS

## How CloudFront caching works

It's important to understand that CloudFront, by default, **respects cache headers given by the origin**, that is, the server it's proxying requests to.

### Default cache behaviour

Consider an origin server that doesn't give any `Cache-Control` headers. Any changes you make to its responses **will be reflected immediately** on the CloudFront distribution. That's is because this module will **by default** not cache such objects at all. This is a sensible default, because the AWS default TTL for CloudFront is 24 hours, and for an origin that doesn't explicitly send `Cache-Control` headers, it's rarely the desired behaviour: your site will be serving stale content for up to 24 hours. Users will be sad, and engineers will be yelled at.

Having immediate updates on CloudFront is convenient, but the downside is that every request for every file will be forwarded to your origin, to make sure the CloudFront cache still has the latest version. This can increase request latency for users, and infrastructure costs for you.

### Specifying cache lifetimes on the origin

Let's say we're serving static files from an S3 bucket. Using the official [AWS CLI](https://aws.amazon.com/cli/), you can specify cache lifetimes as your objects are uploaded:

```bash
aws s3 cp --cache-control=no-store,must-revalidate index.html "s3://my-bucket/"
aws s3 cp --cache-control=max-age=31536000 static/image-v123.jpg "s3://my-bucket/"
```

This will upload `index.html` so that CloudFront will **never** serve its content to a user, without first checking that it's not been updated on S3. However, `image-v123.jpg` will be uploaded with cache headers that allow CloudFront to keep its copy for that object **forever** (well, technically 1 year, which is the maximum recommended value for `max-age`; in practice CloudFront will probably evict it before that for other reasons).

The above is a good middle ground caching strategy, for when you want immediate updates for your HTML documents (e.g. `index.html`), but static assets (e.g. `image-v123.jpg`) can be cached for much longer. This means that for the HTML document itself, you won't get any boost from CloudFront, but as the browser starts downloading the various linked static assets, they can be served directly from the CloudFront edge location, which should be much closer to the user, geographically. When you need to update the linked image, instead of updating `image-v123.jpg`, you should instead upload `image-v124.jpg`, and update any links in `index.html` to point to the new version. This ensures that:

1. Users will see the new document (including its updated images) immediately
1. Users won't see an inconsistent version of the document, where the document content is updated, but it's still showing the old images

### Overriding cache lifetimes on CloudFront

If your origin server doesn't give out sensible cache control headers, or you're just feeling lazy, this module supports overriding cache behaviour on CloudFront, effectively ignoring anything your origin says about caching objects.

That is, if you specify `cache_ttl_override = 0` for your site, every object will always be fetched from the origin, for every request. Importantly, though, this won't invalidate objects that *are already* in the CloudFront cache with a longer TTL. If you have an object that's "stuck" in your cache and you can't shake it, the CloudFront feature you're looking for is [file invalidation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html).

Conversely, if you specify `cache_ttl_override = 300`, every object will stay in CloudFront for 5 minutes, regardless of its cache headers. This can be a good performance boost for your site, since only 1 request per file per 5 minutes will need to go all the way to the origin, and all the others can be served immediately from the CloudFront edge location. Keep in mind the aforementioned warning about "inconsistent versions", however: each object has their own TTL counter, so `index.html` and `image.jpg` may update at different times in the cache, even if you update content at your origin at the same time.

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| add_response_headers | Map of HTTP headers (if any) to add to outgoing responses before sending them to clients | map | `<map>` | no |
| basic_auth_body | When using HTTP Basic Auth, and authentication has failed, this will be displayed by the browser as the page content | string | `"Unauthorized"` | no |
| basic_auth_password | When non-empty, require this password with HTTP Basic Auth | string | `""` | no |
| basic_auth_realm | When using HTTP Basic Auth, this will be displayed by the browser in the auth prompt | string | `"Authentication Required"` | no |
| basic_auth_username | When non-empty, require this username with HTTP Basic Auth | string | `""` | no |
| cache_ttl_override | When >= 0, override the cache behaviour for ALL objects in the origin, so that they stay in the CloudFront cache for this amount of seconds | string | `"-1"` | no |
| cloudfront_price_class | CloudFront price class to use (`100`, `200` or `"All"`, see https://aws.amazon.com/cloudfront/pricing/) | string | `"100"` | no |
| comment_prefix | This will be included in comments for resources that are created | string | `"Reverse proxy: "` | no |
| default_root_object | The object to return when the root URL is requested | string | `""` | no |
| lambda_logging_enabled | When true, writes information about incoming requests to the Lambda function's CloudWatch group | string | `"false"` | no |
| name_prefix | Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed, for S3 bucket name compatibility) | string | `"aws-reverse-proxy---"` | no |
| origin_custom_header_name | Name of a custom header to send to the origin; this can be used to convey an authentication header to the origin, for example | string | `"X-Custom-Origin-Header"` | no |
| origin_custom_header_value | Value of a custom header to send to the origin; see `origin_custom_header_name` | string | `""` | no |
| origin_custom_port | When > 0, use this port for communication with the origin server, instead of relevant standard port | string | `"0"` | no |
| origin_url | Base URL for proxy upstream site (e.g. `"https://example.com/"`) | string | n/a | yes |
| override_response_body | Same as `override_response_status` | string | `""` | no |
| override_response_status | When this and the other `override_response_*` variables are non-empty, skip sending the request to the origin altogether, and instead respond as instructed here | string | `""` | no |
| override_response_status_description | Same as `override_response_status` | string | `""` | no |
| site_domain | Domain on which the reverse proxy will be made available (e.g. `"www.example.com"`) | string | n/a | yes |
| tags | AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/ | map | `<map>` | no |
| viewer_https_only | Set this to `false` if you need to support insecure HTTP access for clients, in addition to HTTPS | string | `"true"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudfront_id | The ID of the CloudFront distribution that's used for hosting the content |
| site_domain | Domain on which the site will be made available |
<!-- terraform-docs:end -->
