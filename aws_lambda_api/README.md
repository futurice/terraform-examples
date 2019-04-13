# aws_lambda_api

This module creates a Lambda function, and makes it available via a custom domain, complete with SSL termination: e.g. `https://api.example.com/`. This includes:

- DNS records on [Route 53](https://aws.amazon.com/route53/)
- An SSL certificate for the domain from [ACM](https://aws.amazon.com/certificate-manager/)
- [API Gateway](https://aws.amazon.com/api-gateway/) configuration for invoking the function over HTTP
- A [Lambda](https://aws.amazon.com/lambda/) function built from your JavaScript code

## Example 1: Simple API

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
# Lambda functions can only be uploaded as ZIP files, so we need to package our JS file into one
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/index.js"
  output_path = "${path.module}/lambda.zip"
}

module "my_api" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_lambda_api#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_lambda_api?ref=v11.0"

  api_domain             = "api.example.com"
  lambda_logging_enabled = true

  # lambda_zip.output_path will be absolute, i.e. different on different machines.
  # This can cause Terraform to notice differences that aren't actually there, so let's convert it to a relative one.
  # https://github.com/hashicorp/terraform/issues/7613#issuecomment-332238441
  function_zipfile = "${substr(data.archive_file.lambda_zip.output_path, length(path.cwd) + 1, -1)}"
}
```

After `terraform apply`, you should be able to visit `https://api.example.com/`, and be greeted by the above `Hello World!` message.

Because we included the `lambda_logging_enabled` option, you can also log into CloudWatch and check out the properties Lambda makes available in the `event` and `context` properties.

The associated API Gateway has been configured to route **all requests** to our Lambda function. Try visiting `https://api.example.com/foo/bar?baz=123` for instance, and you should get the same message, but with different parameters in the `event` object. This allows you to implement arbitrary routing rules in JavaScript, without having to define them in API Gateway also.

## Example 2: Adding a build step

Say you want to do something non-trivial in your Lambda. This probably means installing some libraries from [npm](https://www.npmjs.com/), and possibly writing the Lambda in [TypeScript](https://www.typescriptlang.org/).

An [example project](./example-project) is included with these docs. It demonstrates a simple workflow for:

1. Compiling your Lambda function from TypeScript
1. Including external dependencies from npm (the [`one-liner-joke`](https://www.npmjs.com/package/one-liner-joke) package serves as an example)
1. Releasing code changes via Terraform

Importantly, the most recent compiled version of the Lambda function should always exist in `example-project/dist/lambda.zip`, **and be committed to version control**. This seems counter to best practices, but otherwise developers who have just cloned your Terraform repo will be unable to e.g. `terraform apply`, before installing the full `node` toolchain locally, to be able to compile the Lambda function. The same applies to your CI server, for example. This may not be the correct workflow for larger projects, however; see below for suggestions in that regard.

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up, and a DNS zone for `example.com` configured on Route 53:

```tf
module "my_api" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_lambda_api#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_lambda_api?ref=v11.0"

  api_domain             = "api.example.com"
  lambda_logging_enabled = true
  function_zipfile       = "./path/to/example-project/dist/lambda.zip"
}
```

After `terraform apply`, you should be able to receive a random joke with:

```bash
$ curl https://api.example.com
{
  "body": "You look like a before picture.",
  "tags": [
    "insults"
  ]
}
```

Whenever you make changes to the function code, make sure you run `build.sh` again, commit the result, and then `terraform apply` to deploy your changes.

## Example 3: Separating Lambda code from infra code

Bundling the code and build artifacts for your Lambda function is all well and good when you just want to get things done. However, for a larger or more active project, you're probably better off separating the JavaScript project for the Lambda function into a separate repository. In that case, the process usually looks something like this:

1. Changes to the Lambda code are pushed to version control
1. A CI process picks up the changes, builds the code into a zipfile
1. The zipfile gets named with some versioning scheme, e.g. `lambda-v123.zip`
1. The CI process uploads the zipfile into an S3 bucket
1. The release is made by updating the Terraform config accordingly

This also makes it easy to support multiple environments, and release promotions between them. For example:

```tf
resource "aws_s3_bucket" "my_builds" {
  bucket = "my-builds"
}

module "my_api_stage" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_lambda_api#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_lambda_api?ref=v11.0"

  api_domain         = "api-stage.example.com"
  function_s3_bucket = "${aws_s3_bucket.my_builds.id}"
  function_zipfile   = "lambda-v123.zip"

  function_env_vars = {
    ENV_NAME = "stage"
  }
}

module "my_api_prod" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_lambda_api#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_lambda_api?ref=v11.0"

  api_domain         = "api-prod.example.com"
  function_s3_bucket = "${aws_s3_bucket.my_builds.id}"
  function_zipfile   = "lambda-v122.zip"

  function_env_vars = {
    ENV_NAME = "prod"
  }
}
```

You'll note how the `stage` environment is running the latest `v123` release, while `prod` is still on the previous `v122` release. Once the `v123` release has been thoroughly tested on the `stage` environment, it can be promoted to `prod` by changing the `function_zipfile` variable, and issuing a `terraform apply`. This process supports immutable releases, easy rollbacks, and an audit trail of past releases.

## Example 4: Releasing without Terraform

Sometimes it's convenient to let your CI perform the release unattended. One way to accomplish this is to use just `function_zipfile = "lambda-stage.zip"` and `function_zipfile = "lambda-prod.zip"` in your Terraform configuration, but then do something like this for releases to `stage`:

```bash
./build.sh
aws s3 cp ./dist/lambda.zip s3://my-builds/lambda-stage.zip
aws lambda update-function-code --function-name my-stage-function-name --s3-bucket my-builds --s3-key lambda-stage.zip
```

And then to promote the current `stage` to `prod`:

```bash
aws s3 cp s3://my-builds/lambda-stage.zip s3://my-builds/lambda-prod.zip
aws lambda update-function-code --function-name my-prod-function-name --s3-bucket my-builds --s3-key lambda-prod.zip
```

...or some variation thereof. You get the idea.

## Debugging API Gateway

If something isn't working right with your API Gateway, set `api_gateway_logging_level = "INFO"`. Additionally, you need to add the following **global configuration** for your API Gateway:

```tf
resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = "${aws_iam_role.apigateway_cloudwatch_logging.arn}"
}

resource "aws_iam_role" "apigateway_cloudwatch_logging" {
  name = "apigateway-cloudwatch-logging"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "apigateway_cloudwatch_logging" {
  name = "apigateway-cloudwatch-logging"
  role = "${aws_iam_role.apigateway_cloudwatch_logging.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
```

Otherwise API Gateway won't have permission to write logs to CloudWatch.

## Supporting CORS

Your API can easily support CORS, if needed. For example:

```js
// https://enable-cors.org/server_nginx.html
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST,OPTIONS,GET,PUT,PATCH,DELETE",
  "Access-Control-Allow-Headers": "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range",
  "Access-Control-Expose-Headers": "Content-Length,Content-Range",
};

exports.handler = function(event, context, callback) {
  console.log("Lambda function event:", event);
  console.log("Lambda function context:", context);
  if (event.httpMethod === "OPTIONS") { // this is (probably) a CORS preflight request
    callback(null, {
      statusCode: 200,
      headers: CORS_HEADERS,
    });
  } else { // this is a regular request
    callback(null, {
      statusCode: 200,
      headers: {
        ...CORS_HEADERS,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ Hello: "World!" }),
    });
  }
};
```

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| api_domain | Domain on which the Lambda will be made available (e.g. `"api.example.com"`) | string | n/a | yes |
| api_gateway_cloudwatch_metrics | When true, sends metrics to CloudWatch | string | `"false"` | no |
| api_gateway_logging_level | Either `"OFF"`, `"INFO"` or `"ERROR"`; note that this requires having a CloudWatch log role ARN globally in API Gateway Settings | string | `"OFF"` | no |
| comment_prefix | This will be included in comments for resources that are created | string | `"Lambda API: "` | no |
| function_env_vars | Which env vars (if any) to invoke the Lambda with | map | `<map>` | no |
| function_handler | Instructs Lambda on which function to invoke within the ZIP file | string | `"index.handler"` | no |
| function_runtime | Which node.js version should Lambda use for this function | string | `"nodejs8.10"` | no |
| function_s3_bucket | When provided, the zipfile is retrieved from an S3 bucket by this name instead (filename is still provided via `function_zipfile`) | string | `""` | no |
| function_timeout | The amount of time your Lambda Function has to run in seconds | string | `"3"` | no |
| function_zipfile | Path to a ZIP file that will be installed as the Lambda function (e.g. `"my-api.zip"`) | string | n/a | yes |
| lambda_logging_enabled | When true, writes any console output to the Lambda function's CloudWatch group | string | `"false"` | no |
| memory_size | Amount of memory in MB your Lambda Function can use at runtime | string | `"128"` | no |
| name_prefix | Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed, for S3 bucket name compatibility) | string | `"aws-lambda-api---"` | no |
| stage_name | Name of the single stage created for the API on API Gateway | string | `"default"` | no |
| tags | AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/ | map | `<map>` | no |
| throttling_burst_limit | How many burst requests should the API process at most; see https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-request-throttling.html | string | `"5000"` | no |
| throttling_rate_limit | How many sustained requests per second should the API process at most; see https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-request-throttling.html | string | `"10000"` | no |

## Outputs

| Name | Description |
|------|-------------|
| api_gw_invoke_url | This URL can be used to invoke the Lambda through the API Gateway |
| function_name | This is the unique name of the Lambda function that was created |
<!-- terraform-docs:end -->
