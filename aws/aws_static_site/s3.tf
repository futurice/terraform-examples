# Query the current AWS region so we know its S3 endpoint
data "aws_region" "current" {}

# Create the S3 bucket in which the static content for the site should be hosted
resource "aws_s3_bucket" "this" {
  count  = "${var.bucket_override_name == "" ? 1 : 0}"
  bucket = "${local.bucket_name}"
  tags   = "${var.tags}"

  # Add a CORS configuration, so that we don't have issues with webfont loading
  # http://www.holovaty.com/writing/cors-ie-cloudfront/
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }

  # Enable website hosting
  # Note, though, that when accessing the bucket over its SSL endpoint, the index_document will not be used
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# Use a bucket policy (instead of the simpler acl = "public-read") so we don't need to always remember to upload objects with:
# $ aws s3 cp --acl public-read ...
# https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl
resource "aws_s3_bucket_policy" "this" {
  depends_on = ["aws_s3_bucket.this"]                      # because we refer to the bucket indirectly, we need to explicitly define the dependency
  count      = "${var.bucket_override_name == "" ? 1 : 0}"
  bucket     = "${local.bucket_name}"

  # https://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies.html#example-bucket-policies-use-case-2
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${local.bucket_name}/*",
      "Condition": {
        "StringEquals": {
          "aws:UserAgent": "${random_string.s3_read_password.result}"
        }
      }
    }
  ]
}
POLICY
}
