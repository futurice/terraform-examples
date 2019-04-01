# Based on: https://www.terraform.io/docs/providers/aws/guides/serverless-with-aws-lambda-and-api-gateway.html
# See also: https://github.com/hashicorp/terraform/issues/10157
# See also: https://github.com/carrot/terraform-api-gateway-cors-module/

# https://www.terraform.io/docs/providers/aws/r/lambda_function.html
resource "aws_lambda_function" "this" {
  function_name    = "${local.prefix_with_domain}"
  filename         = "${var.function_zipfile}"
  source_code_hash = "${base64sha256(file("${var.function_zipfile}"))}"
  handler          = "${var.function_handler}"
  runtime          = "${var.function_runtime}"
  role             = "${aws_iam_role.this.arn}"

  environment {
    variables = "${var.function_env_vars}"
  }
}
