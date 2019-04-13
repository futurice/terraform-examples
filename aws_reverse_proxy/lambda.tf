locals {
  config = {
    basic_auth_username                  = "${var.basic_auth_username}"
    basic_auth_password                  = "${var.basic_auth_password}"
    basic_auth_realm                     = "${var.basic_auth_realm}"
    basic_auth_body                      = "${var.basic_auth_body}"
    override_response_status             = "${var.override_response_status}"
    override_response_status_description = "${var.override_response_status_description}"
    override_response_body               = "${var.override_response_body}"
  }
}

# Lambda@Edge functions don't support environment variables, so let's inline the relevant parts of the config to the JS file.
# (see: "error creating CloudFront Distribution: InvalidLambdaFunctionAssociation: The function cannot have environment variables")
data "template_file" "lambda" {
  template = "${file("${path.module}/lambda.tpl.js")}"

  vars = {
    config               = "${jsonencode(local.config)}"             # single quotes need to be escaped, lest we end up with a parse error on the JS side
    add_response_headers = "${jsonencode(var.add_response_headers)}" # ^ ditto
  }
}

# Lambda functions can only be uploaded as ZIP files, so we need to package our JS file into one
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    filename = "lambda.js"
    content  = "${data.template_file.lambda.rendered}"
  }
}

resource "aws_lambda_function" "viewer_request" {
  provider = "aws.us_east_1" # because: error creating CloudFront Distribution: InvalidLambdaFunctionAssociation: The function must be in region 'us-east-1'

  # lambda_zip.output_path will be absolute, i.e. different on different machines.
  # This can cause Terraform to notice differences that aren't actually there, so let's convert it to a relative one.
  # https://github.com/hashicorp/terraform/issues/7613#issuecomment-332238441
  filename = "${substr(data.archive_file.lambda_zip.output_path, length(path.cwd) + 1, -1)}"

  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  function_name    = "${local.prefix_with_domain}---viewer_request"
  role             = "${aws_iam_role.this.arn}"
  description      = "${var.comment_prefix}${var.site_domain} (request handler)"
  handler          = "lambda.viewer_request"
  runtime          = "nodejs8.10"
  publish          = true                                                        # because: error creating CloudFront Distribution: InvalidLambdaFunctionAssociation: The function ARN must reference a specific function version. (The ARN must end with the version number.)
  tags             = "${var.tags}"
}

resource "aws_lambda_function" "viewer_response" {
  provider = "aws.us_east_1" # because: error creating CloudFront Distribution: InvalidLambdaFunctionAssociation: The function must be in region 'us-east-1'

  # lambda_zip.output_path will be absolute, i.e. different on different machines.
  # This can cause Terraform to notice differences that aren't actually there, so let's convert it to a relative one.
  # https://github.com/hashicorp/terraform/issues/7613#issuecomment-332238441
  filename = "${substr(data.archive_file.lambda_zip.output_path, length(path.cwd) + 1, -1)}"

  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  function_name    = "${local.prefix_with_domain}---viewer_response"
  role             = "${aws_iam_role.this.arn}"
  description      = "${var.comment_prefix}${var.site_domain} (response handler)"
  handler          = "lambda.viewer_response"
  runtime          = "nodejs8.10"
  publish          = true                                                         # because: error creating CloudFront Distribution: InvalidLambdaFunctionAssociation: The function ARN must reference a specific function version. (The ARN must end with the version number.)
  tags             = "${var.tags}"
}

# Allow Lambda@Edge to invoke our functions
resource "aws_iam_role" "this" {
  name = "${local.prefix_with_domain}"
  tags = "${var.tags}"

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
