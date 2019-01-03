data "aws_region" "backup" {}

resource "aws_s3_bucket" "backup" {
  bucket = "${var.docker_host_hostname}-backup"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    # When the backup is older than a day, move it to Glacier
    noncurrent_version_transition {
      days          = 1
      storage_class = "GLACIER"
    }

    # When it's older than a year, remove it (though the latest one never expires)
    noncurrent_version_expiration {
      days = 365
    }
  }
}

resource "aws_iam_user" "backup" {
  name = "${var.docker_host_hostname}-backup"
}

resource "aws_iam_access_key" "backup" {
  user = "${aws_iam_user.backup.name}"
}

resource "aws_iam_user_policy" "backup" {
  name = "${var.docker_host_hostname}-backup"
  user = "${aws_iam_user.backup.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.backup.id}",
        "arn:aws:s3:::${aws_s3_bucket.backup.id}/*"
      ]
    }
  ]
}
EOF
}
