output "bucket_name" {
  description = "The name of the S3 bucket that's used for hosting the content (either auto-generated or externally provided)"
  value       = "${local.bucket_name}"
}

output "cloudfront_id" {
  description = "The ID of the CloudFront distribution that's used for hosting the content"
  value       = "${aws_cloudfront_distribution.this.id}"
}

output "site_domain" {
  description = "Domain on which the static site will be made available"
  value       = "${var.site_domain}"
}

output "bucket_domain_name" {
  description = "Full S3 domain name for the bucket used for hosting the content (e.g. 'aws-static-site---hello-example-com.s3-website.eu-central-1.amazonaws.com')"
  value       = "${local.bucket_domain_name}"
}
