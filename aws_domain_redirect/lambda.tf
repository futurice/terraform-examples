provider "template" {
  version = "~> 2.1"
}

locals {
  config = {
    redirect_url         = "${var.redirect_url}"
    redirect_permanently = "${var.redirect_permanently ? "1" :""}" # booleans need to be encoded as strings
    redirect_with_hsts   = "${var.redirect_with_hsts ? "1" :""}"   # booleans need to be encoded as strings
  }
}

# Because: error creating CloudFront Distribution: InvalidLambdaFunctionAssociation: The function cannot have environment variables.
data "template_file" "lambda" {
  template = "${file("${path.module}/lambda.tpl.js")}"

  vars = {
    config = "${replace(jsonencode(local.config), "'", "\\'")}" # single quotes need to be escaped, lest we end up with a parse error on the JS side
  }
}

provider "archive" {
  version = "~> 1.2"
}

data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    filename = "lambda.js"
    content  = "${data.template_file.lambda.rendered}"
  }
}

resource "aws_lambda_function" "this" {
  provider         = "aws.us_east_1"                                   # because: error creating CloudFront Distribution: InvalidLambdaFunctionAssociation: The function must be in region 'us-east-1'
  filename         = "${path.module}/lambda.zip"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  function_name    = "${local.prefix_with_domain}"
  role             = "${aws_iam_role.this.arn}"
  description      = "Redirect for domain: ${var.redirect_domain}"
  handler          = "lambda.viewer_request"
  runtime          = "nodejs8.10"
  publish          = true                                              # because: error creating CloudFront Distribution: InvalidLambdaFunctionAssociation: The function ARN must reference a specific function version. (The ARN must end with the version number.)
}

# Allow Lambda@Edge to invoke our functions
resource "aws_iam_role" "this" {
  name = "${local.prefix_with_domain}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Allow writing logs to CloudWatch from our functions
resource "aws_iam_policy" "this" {
  count = "${var.lambda_logging_enabled ? 1 : 0}"
  name  = "${local.prefix_with_domain}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = "${var.lambda_logging_enabled ? 1 : 0}"
  role       = "${aws_iam_role.this.name}"
  policy_arn = "${aws_iam_policy.this.arn}"
}
