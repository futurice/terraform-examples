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
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_lambda_cronjob?ref=v11.0"

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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| comment_prefix | This will be included in comments for resources that are created | string | `"Lambda Cronjob: "` | no |
| cronjob_name | Name which will be used to create your Lambda function (e.g. `"my-important-cronjob"`) | string | n/a | yes |
| function_env_vars | Which env vars (if any) to invoke the Lambda with | map | `<map>` | no |
| function_handler | Instructs Lambda on which function to invoke within the ZIP file | string | `"index.handler"` | no |
| function_runtime | Which node.js version should Lambda use for this function | string | `"nodejs8.10"` | no |
| function_s3_bucket | When provided, the zipfile is retrieved from an S3 bucket by this name instead (filename is still provided via `function_zipfile`) | string | `""` | no |
| function_timeout | The amount of time your Lambda Function has to run in seconds | string | `"3"` | no |
| function_zipfile | Path to a ZIP file that will be installed as the Lambda function (e.g. `"my-cronjob.zip"`) | string | n/a | yes |
| lambda_logging_enabled | When true, writes any console output to the Lambda function's CloudWatch group | string | `"false"` | no |
| memory_size | Amount of memory in MB your Lambda Function can use at runtime | string | `"128"` | no |
| name_prefix | Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed, for S3 bucket name compatibility) | string | `"aws-lambda-cronjob---"` | no |
| schedule_expression | How often to run the Lambda (see https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html); e.g. `"rate(15 minutes)"` or `"cron(0 12 * * ? *)"` | string | `"rate(60 minutes)"` | no |
| tags | AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/ | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| function_name | This is the unique name of the Lambda function that was created |
<!-- terraform-docs:end -->
