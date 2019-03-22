resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_prefix}${replace("${var.redirect_domain}", "/[^a-z0-9-]+/", "-")}" # only lowercase alphanumeric characters and hyphens are allowed in S3 bucket names

  # https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl
  acl = "public-read"

  website {
    redirect_all_requests_to = "${var.redirect_url}"
  }
}
