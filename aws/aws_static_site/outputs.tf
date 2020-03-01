output "bucket_name" {
  description = "The name of the S3 bucket that's used for hosting the content (either auto-generated or externally provided)"

  # Terraform isn't particularly helpful when you want to depend on the existence of a resource which may have count 0 or 1, like our bucket.
  # This is a hacky way of only resolving the bucket_name output once the bucket exists (if created by us).
  # https://github.com/hashicorp/terraform/issues/16580#issuecomment-342573652
  value = "${local.bucket_name}${replace("${element(concat(aws_s3_bucket.this.*.bucket, list("")), 0)}", "/.*/", "")}"
}

output "cloudfront_id" {
  description = "The ID of the CloudFront distribution that's used for hosting the content"
  value       = "${module.aws_reverse_proxy.cloudfront_id}"
}

output "site_domain" {
  description = "Domain on which the static site will be made available"
  value       = "${var.site_domain}"
}

output "bucket_domain_name" {
  description = "Full S3 domain name for the bucket used for hosting the content (e.g. `\"aws-static-site---hello-example-com.s3-website.eu-central-1.amazonaws.com\"`)"
  value       = "${local.bucket_domain_name}"
}
