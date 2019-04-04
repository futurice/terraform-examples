# aws_lambda_cronjob

This module creates a Lambda function, and configures it to be invoked on a schedule.

## Example 1: Simple cronjob

First, write down some simple code to deploy in a file called `index.js`:

```js
exports.handler = function(event, context, callback) {
  console.log("Lambda function event:", event);
  console.log("Lambda function context:", context);
  callback(null);
};
```

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up:

```tf
# Lambda functions can only be uploaded as ZIP files, so we need to package our JS file into one
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/index.js"
  output_path = "${path.module}/lambda.zip"
}

module "my_cronjob" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_lambda_cronjob#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v8.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_lambda_cronjob?ref=v8.0"

  cronjob_name           = "my-cronjob"
  schedule_expression    = "rate(5 minutes)" # note: full cron expressions are also supported
  lambda_logging_enabled = true

  # lambda_zip.output_path will be absolute, i.e. different on different machines.
  # This can cause Terraform to notice differences that aren't actually there, so let's convert it to a relative one.
  # https://github.com/hashicorp/terraform/issues/7613#issuecomment-332238441
  function_zipfile = "${substr(data.archive_file.lambda_zip.output_path, length(path.cwd) + 1, -1)}"
}
```

After `terraform apply`, because we included the `lambda_logging_enabled` option, you can log into CloudWatch and check out the properties Lambda makes available in the `event` and `context` properties.

## Example 2: Other options for deploying code

As this module is a close relative of [`aws_lambda_api`](../aws_lambda_api), the other options for deploying code are equally applicable here.

<!-- terraform-docs:begin -->
<!-- terraform-docs:end -->
