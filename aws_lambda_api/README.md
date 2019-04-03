# aws_lambda_api

This module creates a Lambda function, and makes it available via a custom domain, complete with SSL termination: e.g. `https://api.example.com/`. This includes:

- DNS records on [Route 53](https://aws.amazon.com/route53/)
- A [CloudFront](https://aws.amazon.com/cloudfront/) distribution for SSL termination
- An SSL certificate for the distribution from [ACM](https://aws.amazon.com/certificate-manager/)
- A [Lambda](https://aws.amazon.com/lambda/) function built from your JavaScript code
- [API Gateway](https://aws.amazon.com/api-gateway/) configuration for invoking the function over HTTP

## Example 1: Simple API

**Important:** CloudFront operations are generally very slow. Your `terraform apply` may take anywhere **from 10 minutes up to 45 minutes** to complete.

First, write down some simple code to deploy in a file called `index.js`:

```js
exports.handler = function(event, context, callback) {
  console.log("Lambda function event:", event);
  console.log("Lambda function context:", context);
  callback(null, {
    // See here for docs on this response object:
    // https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-output-format
    statusCode: 200,
    headers: { "Content-Type": "text/plain; charset=utf-8" },
    body: "Hello World!"
  });
};
```

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up, and a DNS zone for `example.com` configured on Route 53:

```tf
# Several AWS services (such as ACM & Lambda@Edge) are presently only available in the US East region.
# To be able to use them, we need a separate AWS provider for that region, which can be used with an alias.
# https://docs.aws.amazon.com/acm/latest/userguide/acm-services.html
# https://www.terraform.io/docs/configuration/providers.html#multiple-provider-instances
provider "aws" {
  alias                   = "us_east_1"
  shared_credentials_file = "./aws.key" # make sure you customize this to match your regular AWS provider config
  region                  = "us-east-1"
}

# Lambda functions can only be uploaded as ZIP files, so we need to package our JS file into one
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/index.js"
  output_path = "${path.module}/lambda.zip"
}

module "my_api" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_lambda_api#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v7.3...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_lambda_api?ref=v7.3"

  api_domain             = "api.example.com"
  lambda_logging_enabled = true

  # lambda_zip.output_path will be absolute, i.e. different on different machines.
  # This can cause Terraform to notice differences that aren't actually there, so let's convert it to a relative one.
  # https://github.com/hashicorp/terraform/issues/7613#issuecomment-332238441
  function_zipfile = "${substr(data.archive_file.lambda_zip.output_path, length(path.cwd) + 1, -1)}"
}
```

After `terraform apply` (which may take a **very** long time), you should be able to visit `https://api.example.com/`, and be greeted by the above `Hello World!` message.

Because we included the `lambda_logging_enabled` option, you can also log into CloudWatch and check out the properties Lambda makes available in the `event` and `context` properties.

The associated API Gateway has been configured to route **all requests** to our Lambda function. Try visiting `https://api.example.com/foo/bar?baz=123` for instance, and you should get the same message, but with different parameters in the `event` object. This allows you to implement arbitrary routing rules in JavaScript, without having to define them in API Gateway also.

## Example 2: Adding a build step

Say you want to do something non-trivial in your Lambda. This probably means installing some libraries from [npm](https://www.npmjs.com/), and possibly writing the Lambda in [TypeScript](https://www.typescriptlang.org/).

TODO

<!-- terraform-docs:begin -->
TODO
<!-- terraform-docs:end -->
