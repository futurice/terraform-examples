# Repository containing various terraform code

Note: Some examples were taken from https://github.com/futurice/terraform-utils which has formal release process and intended for library building. This repo is designed for looser copy and pasting

- [AWS Examples](#aws-examples)
- [Azure Examples](#azure-examples)
- [Google Cloud Platform Examples Examples](#google-cloud-platform-examples)




# [Jump to aws/](aws/)

# AWS Examples


# [Jump to aws/aws_domain_redirect](aws/aws_domain_redirect)

# aws_domain_redirect

This module implements a domain that redirects clients to another URL. Useful for creating human-friendly shortcuts for deeper links into a site, or for dynamic links (e.g. `download.example.com` always pointing to your latest release).

Main features:

- DNS entries are created automatically
- HTTPS enabled by default
- HTTP Strict Transport Security supported

Optional features:

- Plain HTTP instead of HTTPS
- Sending a permanent redirect (`301 Moved Permanently`) instead of default (`302 Found`)

Resources used:

- Route53 for DNS entries
- ACM for SSL certificates
- CloudFront for proxying requests
- Lambda@Edge for transforming requests
- IAM for permissions

## About CloudFront operations

This module manages CloudFront distributions, and these operations are generally very slow. Your `terraform apply` may take anywhere **from 10 minutes up to 45 minutes** to complete. Be patient: if they start successfully, they almost always finish successfully, it just takes a while.

Additionally, this module uses Lambda@Edge functions with CloudFront. Because Lambda@Edge functions are replicated, [they can't be deleted immediately](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html). This means a `terraform destroy` won't successfully remove all resources on its first run. It should complete successfully when running it again after a few hours, however.

## Example

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up, and a DNS zone for `example.com` configured on Route 53:

```tf
# Lambda@Edge and ACM, when used with CloudFront, need to be used in the US East region.
# Thus, we need a separate AWS provider for that region, which can be used with an alias.
# Make sure you customize this block to match your regular AWS provider configuration.
# https://www.terraform.io/docs/configuration/providers.html#multiple-provider-instances
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "my_redirect" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_domain_redirect#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_domain_redirect?ref=v11.0"

  redirect_domain = "go.example.com"
  redirect_url    = "https://www.futurice.com/careers/"
}
```

Applying this **will take a very long time**, because both ACM and especially CloudFront are quite slow to update. After that, both `http://go.example.com` and `https://go.example.com` should redirect clients to `https://www.futurice.com/careers/`.

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cloudfront_price_class | Price class to use (`100`, `200` or `"All"`, see https://aws.amazon.com/cloudfront/pricing/) | string | `"100"` | no |
| comment_prefix | This will be included in comments for resources that are created | string | `"Domain redirect: "` | no |
| lambda_logging_enabled | When `true`, writes information about incoming requests to the Lambda function's CloudWatch group | string | `"false"` | no |
| name_prefix | Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed, for S3 bucket name compatibility) | string | `"aws-domain-redirect---"` | no |
| redirect_domain | Domain which will redirect to the given `redirect_url`; e.g. `"docs.example.com"` | string | n/a | yes |
| redirect_permanently | Which HTTP status code to use for the redirect; if `true`, uses `301 Moved Permanently`, instead of `302 Found` | string | `"false"` | no |
| redirect_url | The URL this domain redirect should send clients to; e.g. `"https://readthedocs.org/projects/example"` | string | n/a | yes |
| redirect_with_hsts | Whether to send the `Strict-Transport-Security` header with the redirect (recommended for security) | string | `"true"` | no |
| tags | AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/ | map | `<map>` | no |
| viewer_https_only | Set this to `false` if you need to support insecure HTTP access for clients, in addition to HTTPS | string | `"true"` | no |
<!-- terraform-docs:end -->



# [Jump to aws/aws_ec2_ebs_docker_host](aws/aws_ec2_ebs_docker_host)

# aws_ec2_ebs_docker_host

Creates a standalone Docker host on EC2, optionally attaching an external EBS volume for persistent data.

This is convenient for quickly setting up non-production-critical Docker workloads. If you need something fancier, consider e.g. ECS, EKS or Fargate.

## Example 1: Running a docker container

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up:

```tf
module "my_host" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_ec2_ebs_docker_host#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_ec2_ebs_docker_host?ref=v11.0"

  hostname             = "my-docker-host"
  ssh_private_key_path = "~/.ssh/id_rsa"     # if you use shared Terraform state, consider changing this to something that doesn't depend on "~"
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
  allow_incoming_http  = true                # by default, only incoming SSH is allowed; other protocols for the security group are opt-in
}

output "host_ssh_command" {
  description = "Run this command to create a port-forward to the remote docker daemon"
  value       = "ssh -i ${module.my_host.ssh_private_key_path} -o StrictHostKeyChecking=no -L localhost:2377:/var/run/docker.sock ${module.my_host.ssh_username}@${module.my_host.public_ip}"
}
```

After `terraform apply`, and running the `host_ssh_command`, you should be able to connect from your local Docker CLI to the remote daemon, e.g.:

```bash
$ DOCKER_HOST=localhost:2377 docker run -d -p 80:80 nginx
```

Visit the IP address of your host in a browser to make sure it works.

## Example 2: Using a persistent data volume

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up:

```tf
resource "aws_ebs_volume" "my_data" {
  availability_zone = "${module.my_host.availability_zone}" # ensure the volume is created in the same AZ the docker host
  type              = "gp2"                                 # i.e. "Amazon EBS General Purpose SSD"
  size              = 25                                    # in GiB; if you change this in-place, you need to SSH over and run e.g. $ sudo resize2fs /dev/xvdh
}

module "my_host" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_ec2_ebs_docker_host#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_ec2_ebs_docker_host?ref=v11.0"

  hostname             = "my-host"
  ssh_private_key_path = "~/.ssh/id_rsa"                # note that with a shared Terraform state, paths with "~" will become problematic
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
  data_volume_id       = "${aws_ebs_volume.my_data.id}" # attach our EBS data volume
}

output "host_ssh_command" {
  description = "Run this command to check that the data volume got mounted"
  value       = "ssh -i ${module.my_host.ssh_private_key_path} -o StrictHostKeyChecking=no ${module.my_host.ssh_username}@${module.my_host.public_ip} df -h"
}

```

Note that due to [a bug in Terraform](https://github.com/hashicorp/terraform/issues/12570), at the time of writing, you need to apply in two parts:

```bash
$ terraform apply -target aws_ebs_volume.my_data
...
$ terraform apply
...
```

Afterwards, running the `host_ssh_command` should give you something like:

```
Filesystem      Size  Used Avail Use% Mounted on
udev            481M     0  481M   0% /dev
tmpfs            99M  752K   98M   1% /run
/dev/xvda1      7.7G  2.1G  5.7G  27% /
tmpfs           492M     0  492M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           492M     0  492M   0% /sys/fs/cgroup
/dev/loop0       88M   88M     0 100% /snap/core/5328
/dev/loop1       13M   13M     0 100% /snap/amazon-ssm-agent/495
/dev/xvdh        25G   45M   24G   1% /data
tmpfs            99M     0   99M   0% /run/user/1000
```

That is, you can see the 25 GB data volume mounted at `/data`.

## Example 3: Running additional provisioners

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up:

```tf
module "my_host" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_ec2_ebs_docker_host#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_ec2_ebs_docker_host?ref=v11.0"

  hostname             = "my-docker-host"
  ssh_private_key_path = "~/.ssh/id_rsa"
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
}

resource "null_resource" "provisioners" {
  depends_on = ["module.my_host"] # wait until other provisioners within the module have finished

  connection {
    host        = "${module.my_host.public_ip}"
    user        = "${module.my_host.ssh_username}"
    private_key = "${module.my_host.ssh_private_key}"
    agent       = false
  }

  provisioner "remote-exec" {
    inline = ["echo HELLO WORLD"]
  }
}
```

## Example 4: Using the `docker` provider

Note that until [direct support for the SSH protocol in the `docker` provider](https://github.com/terraform-providers/terraform-provider-docker/pull/113) lands in Terraform, this is a bit cumbersome. But it's documented here in case it's useful.

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up:

```tf
module "my_host" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_ec2_ebs_docker_host#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_ec2_ebs_docker_host?ref=v11.0"

  hostname             = "my-docker-host"
  ssh_private_key_path = "~/.ssh/id_rsa"
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
  allow_incoming_http  = true
}

output "docker_tunnel_command" {
  description = "Run this command to create a port-forward to the remote docker daemon"
  value       = "ssh -i ${module.my_host.ssh_private_key_path} -o StrictHostKeyChecking=no -L localhost:2377:/var/run/docker.sock ${module.my_host.ssh_username}@${module.my_host.public_ip}"
}

provider "docker" {
  version = "~> 1.1"
  host    = "tcp://127.0.0.1:2377/" # Important: this is expected to be an SSH tunnel; see "docker_tunnel_command" in $ terraform output
}

resource "docker_image" "nginx" {
  name = "nginx"
}

resource "docker_container" "nginx" {
  image    = "${docker_image.nginx.latest}"
  name     = "nginx"
  must_run = true

  ports {
    internal = 80
    external = 80
  }
}

output "test_link" {
  value = "http://${module.my_host.public_ip}/"
}
```

Because the tunnel won't exist before the host is up, this needs to be applied with:

```bash
$ terraform apply -target module.my_host
```

This should finish by giving you the `docker_tunnel_command` output. Run that in another terminal, and then finish with another `terraform apply`. Afterwards, you should be able to visit the `test_link` and see nginx greeting you.

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allow_incoming_dns | Whether to allow incoming DNS traffic on the host security group | string | `"false"` | no |
| allow_incoming_http | Whether to allow incoming HTTP traffic on the host security group | string | `"false"` | no |
| allow_incoming_https | Whether to allow incoming HTTPS traffic on the host security group | string | `"false"` | no |
| data_volume_id | The ID of the EBS volume to mount as `/data` | string | `""` | no |
| hostname | Hostname by which this service is identified in metrics, logs etc | string | `"aws-ec2-ebs-docker-host"` | no |
| instance_ami | See https://cloud-images.ubuntu.com/locator/ec2/ for options | string | `"ami-0bdf93799014acdc4"` | no |
| instance_type | See https://aws.amazon.com/ec2/instance-types/ for options; for example, typical values for small workloads are `"t2.nano"`, `"t2.micro"`, `"t2.small"`, `"t2.medium"`, and `"t2.large"` | string | `"t2.micro"` | no |
| reprovision_trigger | An arbitrary string value; when this value changes, the host needs to be reprovisioned | string | `""` | no |
| root_volume_size | Size (in GiB) of the EBS volume that will be created and mounted as the root fs for the host | string | `"8"` | no |
| ssh_private_key_path | SSH private key file path, relative to Terraform project root | string | `"ssh.private.key"` | no |
| ssh_public_key_path | SSH public key file path, relative to Terraform project root | string | `"ssh.public.key"` | no |
| ssh_username | Default username built into the AMI (see 'instance_ami') | string | `"ubuntu"` | no |
| swap_file_size | Size of the swap file allocated on the root volume | string | `"512M"` | no |
| swap_swappiness | Swappiness value provided when creating the swap file | string | `"10"` | no |
| tags | AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/ | map | `<map>` | no |
| vpc_id | ID of the VPC our host should join; if empty, joins your Default VPC | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| availability_zone | AWS Availability Zone in which the EC2 instance was created |
| hostname | Hostname by which this service is identified in metrics, logs etc |
| instance_id | AWS ID for the EC2 instance used |
| public_ip | Public IP address assigned to the host by EC2 |
| security_group_id | Security Group ID, for attaching additional security rules externally |
| ssh_private_key | SSH private key that can be used to access the EC2 instance |
| ssh_private_key_path | Path to SSH private key that can be used to access the EC2 instance |
| ssh_username | Username that can be used to access the EC2 instance over SSH |
<!-- terraform-docs:end -->



# [Jump to aws/aws_lambda_api](aws/aws_lambda_api)

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



# [Jump to aws/aws_lambda_cronjob](aws/aws_lambda_cronjob)

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



# [Jump to aws/aws_mailgun_domain](aws/aws_mailgun_domain)

# aws_mailgun_domain

Uses the [Terraform Mailgun provider](https://www.terraform.io/docs/providers/mailgun/index.html) to set up and verify a domain, so you can use [Mailgun](https://www.mailgun.com/) for sending email from it.

## Example

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up, and a DNS zone for `example.com` configured on Route 53:

```tf
variable "mailgun_api_key" {
  description = "Your Mailgun API key"
}

variable "demo_email_address" {
  description = "Enter your email (e.g. me@gmail.com), so you'll get a copy-pasteable curl command for testing the API immediately"
}

# Configure the Mailgun provider
# https://www.terraform.io/docs/providers/mailgun/index.html
provider "mailgun" {
  version = "~> 0.1"
  api_key = "${var.mailgun_api_key}"
}

module "my_mailgun_domain" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_mailgun_domain#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_mailgun_domain?ref=v11.0"

  mail_domain   = "example.com"
  smtp_password = "SECRET SECRET SECRET"
}

output "demo_curl_command" {
  value = "curl -s --user 'api:${var.mailgun_api_key}' ${module.my_mailgun_domain.api_base_url}messages -F from='Demo <demo@${module.my_mailgun_domain.mail_domain}>' -F to='${var.demo_email_address}' -F subject='Hello' -F text='Testing, testing...'"
}
```

Note that due to [a bug in Terraform](https://github.com/hashicorp/terraform/issues/12570), at the time of writing, you need to apply in two parts:

```bash
$ terraform apply -target module.my_mailgun_domain.mailgun_domain.this
...
$ terraform apply
...
```

After the `terraform apply`, you either need to wait a bit, or if you're impatient, log into your Mailgun control panel and manually trigger the DNS verification. If you're too quick, running the command given by `demo_curl_command` will give you something like:

```json
{
  "message": "The domain is unverified and requires DNS configuration. Log in to your control panel to view required DNS records."
}
```

After Mailgun is happy with your DNS records, however, you should get something like:

```json
{
  "id": "<20190401125249.1.XXXYYYZZZ@example.com>",
  "message": "Queued. Thank you."
}
```

...and you should receive the test email shortly.

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| mail_domain | Domain which you want to use for sending/receiving email (e.g. `"example.com"`) | string | n/a | yes |
| smtp_password | Password that Mailgun will require for sending out SMPT mail via this domain | string | n/a | yes |
| spam_action | See https://www.terraform.io/docs/providers/mailgun/r/domain.html#spam_action | string | `"disabled"` | no |
| tags | AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/ | map | `<map>` | no |
| wildcard | See https://www.terraform.io/docs/providers/mailgun/r/domain.html#wildcard | string | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| api_base_url | Base URL of the Mailgun API for your domain |
| mail_domain | Domain which you want to use for sending/receiving email (e.g. `"example.com"`) |
<!-- terraform-docs:end -->



# [Jump to aws/aws_reverse_proxy](aws/aws_reverse_proxy)

# aws_reverse_proxy

This module implements a website that proxies content from another server.

Main features:

- DNS entries are created automatically
- HTTPS enabled by default
- HTTP Strict Transport Security supported

Optional features:

- HTTP Basic Auth
- Plain HTTP instead of HTTPS
- Cache TTL overrides
- Custom response headers sent to clients
- Custom request headers sent to origin server
- Static response status/body override

Resources used:

- Route53 for DNS entries
- ACM for SSL certificates
- CloudFront for proxying requests
- Lambda@Edge for transforming requests
- IAM for permissions

## About CloudFront operations

This module manages CloudFront distributions, and these operations are generally very slow. Your `terraform apply` may take anywhere **from 10 minutes up to 45 minutes** to complete. Be patient: if they start successfully, they almost always finish successfully, it just takes a while.

Additionally, this module uses Lambda@Edge functions with CloudFront. Because Lambda@Edge functions are replicated, [they can't be deleted immediately](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html). This means a `terraform destroy` won't successfully remove all resources on its first run. It should complete successfully when running it again after a few hours, however.

## Examples

Some common use cases for this module are:

- [Static website hosting with S3](../aws_static_site)
- [Redirecting clients from a domain to another URL](../aws_domain_redirect)
- SSL termination in front of a server/load balancer elsewhere on AWS

## How CloudFront caching works

It's important to understand that CloudFront, by default, **respects cache headers given by the origin**, that is, the server it's proxying requests to.

### Default cache behaviour

Consider an origin server that doesn't give any `Cache-Control` headers. Any changes you make to its responses **will be reflected immediately** on the CloudFront distribution. That's is because this module will **by default** not cache such objects at all. This is a sensible default, because the AWS default TTL for CloudFront is 24 hours, and for an origin that doesn't explicitly send `Cache-Control` headers, it's rarely the desired behaviour: your site will be serving stale content for up to 24 hours. Users will be sad, and engineers will be yelled at.

Having immediate updates on CloudFront is convenient, but the downside is that every request for every file will be forwarded to your origin, to make sure the CloudFront cache still has the latest version. This can increase request latency for users, and infrastructure costs for you.

### Specifying cache lifetimes on the origin

Let's say we're serving static files from an S3 bucket. Using the official [AWS CLI](https://aws.amazon.com/cli/), you can specify cache lifetimes as your objects are uploaded:

```bash
aws s3 cp --cache-control=no-store,must-revalidate index.html "s3://my-bucket/"
aws s3 cp --cache-control=max-age=31536000 static/image-v123.jpg "s3://my-bucket/"
```

This will upload `index.html` so that CloudFront will **never** serve its content to a user, without first checking that it's not been updated on S3. However, `image-v123.jpg` will be uploaded with cache headers that allow CloudFront to keep its copy for that object **forever** (well, technically 1 year, which is the maximum recommended value for `max-age`; in practice CloudFront will probably evict it before that for other reasons).

The above is a good middle ground caching strategy, for when you want immediate updates for your HTML documents (e.g. `index.html`), but static assets (e.g. `image-v123.jpg`) can be cached for much longer. This means that for the HTML document itself, you won't get any boost from CloudFront, but as the browser starts downloading the various linked static assets, they can be served directly from the CloudFront edge location, which should be much closer to the user, geographically. When you need to update the linked image, instead of updating `image-v123.jpg`, you should instead upload `image-v124.jpg`, and update any links in `index.html` to point to the new version. This ensures that:

1. Users will see the new document (including its updated images) immediately
1. Users won't see an inconsistent version of the document, where the document content is updated, but it's still showing the old images

### Overriding cache lifetimes on CloudFront

If your origin server doesn't give out sensible cache control headers, or you're just feeling lazy, this module supports overriding cache behaviour on CloudFront, effectively ignoring anything your origin says about caching objects.

That is, if you specify `cache_ttl_override = 0` for your site, every object will always be fetched from the origin, for every request. Importantly, though, this won't invalidate objects that *are already* in the CloudFront cache with a longer TTL. If you have an object that's "stuck" in your cache and you can't shake it, the CloudFront feature you're looking for is [file invalidation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html).

Conversely, if you specify `cache_ttl_override = 300`, every object will stay in CloudFront for 5 minutes, regardless of its cache headers. This can be a good performance boost for your site, since only 1 request per file per 5 minutes will need to go all the way to the origin, and all the others can be served immediately from the CloudFront edge location. Keep in mind the aforementioned warning about "inconsistent versions", however: each object has their own TTL counter, so `index.html` and `image.jpg` may update at different times in the cache, even if you update content at your origin at the same time.

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| add_response_headers | Map of HTTP headers (if any) to add to outgoing responses before sending them to clients | map | `<map>` | no |
| basic_auth_body | When using HTTP Basic Auth, and authentication has failed, this will be displayed by the browser as the page content | string | `"Unauthorized"` | no |
| basic_auth_password | When non-empty, require this password with HTTP Basic Auth | string | `""` | no |
| basic_auth_realm | When using HTTP Basic Auth, this will be displayed by the browser in the auth prompt | string | `"Authentication Required"` | no |
| basic_auth_username | When non-empty, require this username with HTTP Basic Auth | string | `""` | no |
| cache_ttl_override | When >= 0, override the cache behaviour for ALL objects in the origin, so that they stay in the CloudFront cache for this amount of seconds | string | `"-1"` | no |
| cloudfront_price_class | CloudFront price class to use (`100`, `200` or `"All"`, see https://aws.amazon.com/cloudfront/pricing/) | string | `"100"` | no |
| comment_prefix | This will be included in comments for resources that are created | string | `"Reverse proxy: "` | no |
| default_root_object | The object to return when the root URL is requested | string | `""` | no |
| lambda_logging_enabled | When true, writes information about incoming requests to the Lambda function's CloudWatch group | string | `"false"` | no |
| name_prefix | Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed, for S3 bucket name compatibility) | string | `"aws-reverse-proxy---"` | no |
| origin_custom_header_name | Name of a custom header to send to the origin; this can be used to convey an authentication header to the origin, for example | string | `"X-Custom-Origin-Header"` | no |
| origin_custom_header_value | Value of a custom header to send to the origin; see `origin_custom_header_name` | string | `""` | no |
| origin_custom_port | When > 0, use this port for communication with the origin server, instead of relevant standard port | string | `"0"` | no |
| origin_url | Base URL for proxy upstream site (e.g. `"https://example.com/"`) | string | n/a | yes |
| override_response_body | Same as `override_response_status` | string | `""` | no |
| override_response_status | When this and the other `override_response_*` variables are non-empty, skip sending the request to the origin altogether, and instead respond as instructed here | string | `""` | no |
| override_response_status_description | Same as `override_response_status` | string | `""` | no |
| site_domain | Domain on which the reverse proxy will be made available (e.g. `"www.example.com"`) | string | n/a | yes |
| tags | AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/ | map | `<map>` | no |
| viewer_https_only | Set this to `false` if you need to support insecure HTTP access for clients, in addition to HTTPS | string | `"true"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudfront_id | The ID of the CloudFront distribution that's used for hosting the content |
| site_domain | Domain on which the site will be made available |
<!-- terraform-docs:end -->



# [Jump to aws/aws_static_site](aws/aws_static_site)

# aws_static_site

This module implements a website for hosting static content.

Main features:

- DNS entries are created automatically
- S3 bucket is created automatically
- HTTPS enabled by default
- HTTP Strict Transport Security supported
- Direct access to the S3 bucket is prevented

Optional features:

- HTTP Basic Auth
- Plain HTTP instead of HTTPS
- Cache TTL overrides
- Custom response headers sent to clients
- Creating the S3 bucket outside of this module and passing it in via variable

Resources used:

- Route53 for DNS entries
- ACM for SSL certificates
- CloudFront for proxying requests
- Lambda@Edge for transforming requests
- IAM for permissions

## About CloudFront operations

This module manages CloudFront distributions, and these operations are generally very slow. Your `terraform apply` may take anywhere **from 10 minutes up to 45 minutes** to complete. Be patient: if they start successfully, they almost always finish successfully, it just takes a while.

Additionally, this module uses Lambda@Edge functions with CloudFront. Because Lambda@Edge functions are replicated, [they can't be deleted immediately](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html). This means a `terraform destroy` won't successfully remove all resources on its first run. It should complete successfully when running it again after a few hours, however.

## Example 1: Simple static site

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up, and a DNS zone for `example.com` configured on Route 53:

```tf
# Lambda@Edge and ACM, when used with CloudFront, need to be used in the US East region.
# Thus, we need a separate AWS provider for that region, which can be used with an alias.
# Make sure you customize this block to match your regular AWS provider configuration.
# https://www.terraform.io/docs/configuration/providers.html#multiple-provider-instances
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "my_site" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_static_site#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v11.0"

  site_domain = "hello.example.com"
}

resource "aws_s3_bucket_object" "my_index" {
  bucket       = "${module.my_site.bucket_name}"
  key          = "index.html"
  content      = "<pre>Hello World!</pre>"
  content_type = "text/html; charset=utf-8"
}

output "bucket_name" {
  description = "The name of the S3 bucket that's used for hosting the content"
  value       = "${module.my_site.bucket_name}"
}
```

After `terraform apply` (which may take a **very** long time), you should be able to visit `hello.example.com`, be redirected to HTTPS, and be greeted by the above `Hello World!` message.

You may (and probably will) want to upload more files into the bucket outside of Terraform. Using the official [AWS CLI](https://aws.amazon.com/cli/) this could look like:

```bash
aws s3 cp --cache-control=no-store,must-revalidate image.jpg "s3://$(terraform output bucket_name)/"
```

After this, `image.jpg` will be available at `https://hello.example.com/image.jpg`.

## Example 2: Basic Authentication

This module supports password-protecting your site with HTTP Basic Authentication, via a Lambda@Edge function.

Update the `my_site` module in Example 1 as follows:

```tf
module "my_site" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_static_site#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v11.0"

  site_domain = "hello.example.com"

  basic_auth_username = "admin"
  basic_auth_password = "secret"
}
```

After `terraform apply` (which may take a **very** long time), visiting `hello.example.com` should pop out the browser's authentication dialog, and not let you proceed without the above credentials.

## Example 3: Custom response headers

This module supports injecting custom headers into CloudFront responses, via a Lambda@Edge function.

By default, the function only adds `Strict-Transport-Security` headers (as it [significantly improves security](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security#An_example_scenario) with HTTPS), but you may need other customization.

For [additional security hardening of your static site](https://aws.amazon.com/blogs/networking-and-content-delivery/adding-http-security-headers-using-lambdaedge-and-amazon-cloudfront/), update the `my_site` module in Example 1 as follows:

```tf
module "my_site" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_static_site#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v11.0"

  site_domain = "hello.example.com"

  add_response_headers = {
    "Strict-Transport-Security" = "max-age=63072000; includeSubdomains; preload"
    "Content-Security-Policy"   = "default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"
    "X-Content-Type-Options"    = "nosniff"
    "X-Frame-Options"           = "DENY"
    "X-XSS-Protection"          = "1; mode=block"
    "Referrer-Policy"           = "same-origin"
  }
}
```

After `terraform apply` (which may take a **very** long time), visiting `hello.example.com` should give you these extra headers.

It's also possible to override existing headers. For example:

```tf
module "my_site" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_static_site#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_static_site?ref=v11.0"

  site_domain = "hello.example.com"

  add_response_headers = {
    "Server" = "My Secret Origin Server"
  }
}
```

After `terraform apply`, checking with `curl --silent -I https://hello.example.com | grep Server` should give you `My Secret Origin Server` instead of the default `AmazonS3`.

## Example 4: Using your own bucket

If you already have an S3 bucket that you want to use, you can provide e.g. `bucket_override_name = "my-existing-s3-bucket"` as a variable for this module.

When `bucket_override_name` is provided, an S3 bucket is not automatically created for you. Note that you're then also responsible for setting up a bucket policy allowing CloudFront access to the bucket contents.

## How CloudFront caching works

It's important to understand how CloudFront caches the files it proxies from S3. Because this module is built on the `aws_reverse_proxy` module, [everything its documentation says about CloudFront caching](../aws_reverse_proxy#how-cloudfront-caching-works) is relevant here, too.

### Specifying cache lifetimes on S3

It's a good idea to specify cache lifetimes for files individually, as they are uploaded.

For example, to upload a file so that **it's never cached by CloudFront**:

```bash
aws s3 cp --cache-control=no-store,must-revalidate index.html "s3://$(terraform output bucket_name)/"
```

Alternatively, to upload a file so that **CloudFront can cache it forever**:

```bash
aws s3 cp --cache-control=max-age=31536000 static/image-v123.jpg "s3://$(terraform output bucket_name)/"
```

Learn more about [effective caching strategies on CloudFront](../aws_reverse_proxy#specifying-cache-lifetimes-on-the-origin).

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| add_response_headers | Map of HTTP headers (if any) to add to outgoing responses before sending them to clients | map | `<map>` | no |
| basic_auth_body | When using HTTP Basic Auth, and authentication has failed, this will be displayed by the browser as the page content | string | `"Unauthorized"` | no |
| basic_auth_password | When non-empty, require this password with HTTP Basic Auth | string | `""` | no |
| basic_auth_realm | When using HTTP Basic Auth, this will be displayed by the browser in the auth prompt | string | `"Authentication Required"` | no |
| basic_auth_username | When non-empty, require this username with HTTP Basic Auth | string | `""` | no |
| bucket_override_name | When provided, assume a bucket with this name already exists for the site content, instead of creating the bucket automatically (e.g. `"my-bucket"`) | string | `""` | no |
| cache_ttl_override | When >= 0, override the cache behaviour for ALL objects in S3, so that they stay in the CloudFront cache for this amount of seconds | string | `"-1"` | no |
| cloudfront_price_class | CloudFront price class to use (`100`, `200` or `"All"`, see https://aws.amazon.com/cloudfront/pricing/) | string | `"100"` | no |
| comment_prefix | This will be included in comments for resources that are created | string | `"Static site: "` | no |
| default_root_object | The object to return when the root URL is requested | string | `"index.html"` | no |
| lambda_logging_enabled | When true, writes information about incoming requests to the Lambda function's CloudWatch group | string | `"false"` | no |
| name_prefix | Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed, for S3 bucket name compatibility) | string | `"aws-static-site---"` | no |
| site_domain | Domain on which the static site will be made available (e.g. `"www.example.com"`) | string | n/a | yes |
| tags | AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/ | map | `<map>` | no |
| viewer_https_only | Set this to `false` if you need to support insecure HTTP access for clients, in addition to HTTPS | string | `"true"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_domain_name | Full S3 domain name for the bucket used for hosting the content (e.g. `"aws-static-site---hello-example-com.s3-website.eu-central-1.amazonaws.com"`) |
| bucket_name | The name of the S3 bucket that's used for hosting the content (either auto-generated or externally provided) |
| cloudfront_id | The ID of the CloudFront distribution that's used for hosting the content |
| site_domain | Domain on which the static site will be made available |
<!-- terraform-docs:end -->



# [Jump to aws/websites/static_website_ssl_cloudfront_private_s3](aws/websites/static_website_ssl_cloudfront_private_s3)

# Static website hosted using S3 and cloudfront with SSL support

Hosting static website using S3 is a very cost effective approach. Since, S3 website does not support SSL certificate, we use cloudfront for the same. In this example, we host the contents in a private S3 bucket which is used as the origin for cloudfront. We use cloudfront Origin-Access-Identity to access the private content from S3.

## Architecture

![Architecture](images/s3-static-website.png)



# [Jump to azure/](azure/)

# Azure Examples


# [Jump to azure/layers](azure/layers)

# Terraform Azure Layers example

Azure resources may take a long time to create. Sometimes Terraform fails to spot that some resource actually requires another resource that has not been fully created yet. Layers help to ensure that all prerequisite resources for later ones are created before them.

## Try it out

```sh
az login
terraform init
sh create.sh -auto-approve -var resource_name_prefix=${USER}trylayers
```

## Clean up

```sh
sh destroy.sh ${USER}trylayers
```

## Files

- `create.sh` presents a simple hard-coded deployment run that ensures each layer is completed separately.
- `destroy.sh` takes a quick, resource-group based approach to wiping out the whole deployment.
- `layers.tf` lists each layer with associated dependencies.
- `main.tf` contains sample resources used on different layers.
- `variables.sh` declares associated variables with sane defaults.



# [Jump to generic/docker_compose_host](generic/docker_compose_host)

# docker_compose_host

Provisions an existing host to run services defined in a `docker-compose.yml` file.

This is a convenient companion to [`aws_ec2_ebs_docker_host`](https://github.com/futurice/terraform-utils/tree/master/aws_ec2_ebs_docker_host), though any Debian-like host reachable over SSH should work.

Changing the contents of your `docker-compose.yml` file (or any other variables defined for this module) will trigger re-creation of the containers on the next `terraform apply`.

## Example

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up:

```tf
module "my_host" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/docker_compose_host#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_ec2_ebs_docker_host?ref=v11.0"

  hostname             = "my-docker-host"
  ssh_private_key_path = "~/.ssh/id_rsa"
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
  allow_incoming_http  = true
  reprovision_trigger  = "${module.my_docker_compose.reprovision_trigger}"
}

module "my_docker_compose" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/docker_compose_host#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//docker_compose_host?ref=v11.0"

  public_ip          = "${module.my_host.public_ip}"
  ssh_username       = "${module.my_host.ssh_username}"
  ssh_private_key    = "${module.my_host.ssh_private_key}"
  docker_compose_yml = "${file("./docker-compose.yml")}"
}

output "test_link" {
  value = "http://${module.my_host.public_ip}/"
}
```

In your `docker-compose.yml` file, try:

```yml
version: "3"
services:
  nginx:
    image: nginx
    ports:
      - "80:80"
```

After a `terraform apply`, you should be able to visit the `test_link` and see nginx greeting you.

Any changes to the compose file trigger re-provisioning of the services. For example, try changing your services to:

```yml
version: "3"
services:
  whoami:
    image: jwilder/whoami
    ports:
      - "80:8000"
```

When running `terraform apply`, the previous `nginx` service will be stopped and removed, and then the new `whoami` service will be started in its stead. Visiting the `test_link` URL again should give you a different result now.

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| docker_compose_down_command | Command to remove services with; will be run during un- or re-provisioning | string | `"docker-compose stop 00260026 docker-compose rm -f"` | no |
| docker_compose_env | Env-vars (in `.env` file syntax) that will be substituted into docker-compose.yml (see https://docs.docker.com/compose/environment-variables/#the-env-file) | string | `"# No env-vars set"` | no |
| docker_compose_override_yml | Contents for the `docker-compose.override.yml` file (see https://docs.docker.com/compose/extends/#multiple-compose-files) | string | `"# Any docker-compose services defined here will be merged on top of docker-compose.yml
# See: https://docs.docker.com/compose/extends/#multiple-compose-files
version: "3"
"` | no |
| docker_compose_up_command | Command to start services with; you can customize this to do work before/after, or to disable this completely in favor of your own provisioning scripts | string | `"docker-compose pull --quiet 00260026 docker-compose up -d"` | no |
| docker_compose_version | Version of docker-compose to install during provisioning (see https://github.com/docker/compose/releases) | string | `"1.23.2"` | no |
| docker_compose_yml | Contents for the `docker-compose.yml` file | string | n/a | yes |
| public_ip | Public IP address of a host running docker | string | n/a | yes |
| ssh_private_key | SSH private key, which can be used for provisioning the host | string | n/a | yes |
| ssh_username | SSH username, which can be used for provisioning the host | string | `"ubuntu"` | no |

## Outputs

| Name | Description |
|------|-------------|
| reprovision_trigger | Hash of all docker-compose configuration used for this host; can be used as the `reprovision_trigger` input to an `aws_ec2_ebs_docker_host` module |
<!-- terraform-docs:end -->



# [Jump to google_cloud/](google_cloud/)

# Google Cloud Platform Examples


# [Jump to google_cloud/camunda](google_cloud/camunda)

## Provisioning Camunda on Cloud Run + Cloud SQL, using Terraform and Cloud Build

Terraform receipe for running Camunda BPMN workflow engine serverlessly on Cloud Run, using Cloud SQL as the backing store. Custom image building offloaded to Cloud Build. Private container image hosting in Google Container Engine.

Customize the base image in the main.tf locals.

[Provisioning Serverless Camunda on Cloud Run] (https://www.futurice.com/blog/serverless-camunda-terraform-recipe-using-cloud-run-and-cloud-sql) 

[Call external services with at-least-once delevery] (https://www.futurice.com/blog/at-least-once-delivery-for-serverless-camunda-workflow-automation)


    #Camunda # Cloud Run #Cloud SQL #Cloud Build #Container Registry #Docker

### Terraform setup

Create service account credentials for running terraform locally. Then

    export GOOGLE_CREDENTIALS=<PATH TO SERVICE ACCOUNT JSON CREDS>
    gcloud auth activate-service-account --key-file $GOOGLE_CREDENTIALS
    terraform init


Terraform service account, Editor role was not enough
  - to set cloud run service to noauth, had to add Security Admin on camunda cloud run resource (NOT PROJECT level)

### Docker / gcloud Setup

For mac I needed to expose the docker deamon on a tcp port:-

    docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 127.0.0.1:1234:1234 bobrik/socat TCP-LISTEN:1234,fork UNIX-CONNECT:/var/run/docker.sock

Then in bash_profile:

    export DOCKER_HOST=tcp://localhost:1234

Also needed to setup GCR creds in docker

    gcloud auth configure-docker



# [Jump to google_cloud/CQRS_bigquery_memorystore](google_cloud/CQRS_bigquery_memorystore)

## CQRS Bigquery Memorystore Timeseries Analytics with Self Testing Example

Read [Exporting Bigquery results to memorystore](https://www.futurice.com/blog/bigquery-to-memorystore)

    # Bigquery #Memorystore #Cloud Functions #Cloud Scheduler #Pubsub #Cloud Storage

### Getting started

    export GOOGLE_CREDENTIALS=<PATH TO SERVICE ACCOUNT JSON CREDS>
    gcloud auth activate-service-account --key-file $GOOGLE_CREDENTIALS
    terraform init

Note you need to switch on the App Engine API (dependancy of Cloud Scheduler), choose wisely, this is irreversable. The region CANNOT be changed.


### Tips

Shut down memorystore

    terraform destroy -target module.memorystore.google_redis_instance.cache






# [Jump to node_modules/balanced-match](node_modules/balanced-match)

(MIT)

Copyright (c) 2013 Julian Gruber &lt;julian@juliangruber.com&gt;

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



# [Jump to node_modules/balanced-match](node_modules/balanced-match)

# balanced-match

Match balanced string pairs, like `{` and `}` or `<b>` and `</b>`. Supports regular expressions as well!

[![build status](https://secure.travis-ci.org/juliangruber/balanced-match.svg)](http://travis-ci.org/juliangruber/balanced-match)
[![downloads](https://img.shields.io/npm/dm/balanced-match.svg)](https://www.npmjs.org/package/balanced-match)

[![testling badge](https://ci.testling.com/juliangruber/balanced-match.png


# [Jump to node_modules/balanced-match](node_modules/balanced-match)

)](https://ci.testling.com/juliangruber/balanced-match)

## Example

Get the first matching pair of braces:

```js
var balanced = require('balanced-match');

console.log(balanced('{', '}', 'pre{in{nested}}post'));
console.log(balanced('{', '}', 'pre{first}between{second}post'));
console.log(balanced(/\s+\{\s+/, /\s+\}\s+/, 'pre  {   in{nest}   }  post'));
```

The matches are:

```bash
$ node example.js
{ start: 3, end: 14, pre: 'pre', body: 'in{nested}', post: 'post' }
{ start: 3,
  end: 9,
  pre: 'pre',
  body: 'first',
  post: 'between{second}post' }
{ start: 3, end: 17, pre: 'pre', body: 'in{nest}', post: 'post' }
```

## API

### var m = balanced(a, b, str)

For the first non-nested matching pair of `a` and `b` in `str`, return an
object with those keys:

* **start** the index of the first match of `a`
* **end** the index of the matching `b`
* **pre** the preamble, `a` and `b` not included
* **body** the match, `a` and `b` not included
* **post** the postscript, `a` and `b` not included

If there's no match, `undefined` will be returned.

If the `str` contains more `a` than `b` / there are unmatched pairs, the first match that was closed will be used. For example, `{{a}` will match `['{', 'a', '']` and `{a}}` will match `['', 'a', '}']`.

### var r = balanced.range(a, b, str)

For the first non-nested matching pair of `a` and `b` in `str`, return an
array with indexes: `[ <a index>, <b index> ]`.

If there's no match, `undefined` will be returned.

If the `str` contains more `a` than `b` / there are unmatched pairs, the first match that was closed will be used. For example, `{{a}` will match `[ 1, 3 ]` and `{a}}` will match `[0, 2]`.

## Installation

With [npm](https://npmjs.org) do:

```bash
npm install balanced-match
```

## License

(MIT)

Copyright (c) 2013 Julian Gruber &lt;julian@juliangruber.com&gt;

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



# [Jump to node_modules/brace-expansion](node_modules/brace-expansion)

# brace-expansion

[Brace expansion](https://www.gnu.org/software/bash/manual/html_node/Brace-Expansion.html), 
as known from sh/bash, in JavaScript.

[![build status](https://secure.travis-ci.org/juliangruber/brace-expansion.svg)](http://travis-ci.org/juliangruber/brace-expansion)
[![downloads](https://img.shields.io/npm/dm/brace-expansion.svg)](https://www.npmjs.org/package/brace-expansion)
[![Greenkeeper badge](https://badges.greenkeeper.io/juliangruber/brace-expansion.svg)](https://greenkeeper.io/)

[![testling badge](https://ci.testling.com/juliangruber/brace-expansion.png)](https://ci.testling.com/juliangruber/brace-expansion)

## Example

```js
var expand = require('brace-expansion');

expand('file-{a,b,c}.jpg')
// => ['file-a.jpg', 'file-b.jpg', 'file-c.jpg']

expand('-v{,,}')
// => ['-v', '-v', '-v']

expand('file{0..2}.jpg')
// => ['file0.jpg', 'file1.jpg', 'file2.jpg']

expand('file-{a..c}.jpg')
// => ['file-a.jpg', 'file-b.jpg', 'file-c.jpg']

expand('file{2..0}.jpg')
// => ['file2.jpg', 'file1.jpg', 'file0.jpg']

expand('file{0..4..2}.jpg')
// => ['file0.jpg', 'file2.jpg', 'file4.jpg']

expand('file-{a..e..2}.jpg')
// => ['file-a.jpg', 'file-c.jpg', 'file-e.jpg']

expand('file{00..10..5}.jpg')
// => ['file00.jpg', 'file05.jpg', 'file10.jpg']

expand('{{A..C},{a..c}}')
// => ['A', 'B', 'C', 'a', 'b', 'c']

expand('ppp{,config,oe{,conf}}')
// => ['ppp', 'pppconfig', 'pppoe', 'pppoeconf']
```

## API

```js
var expand = require('brace-expansion');
```

### var expanded = expand(str)

Return an array of all possible and valid expansions of `str`. If none are
found, `[str]` is returned.

Valid expansions are:

```js
/^(.*,)+(.+)?$/
// {a,b,...}
```

A comma separated list of options, like `{a,b}` or `{a,{b,c}}` or `{,a,}`.

```js
/^-?\d+\.\.-?\d+(\.\.-?\d+)?$/
// {x..y[..incr]}
```

A numeric sequence from `x` to `y` inclusive, with optional increment.
If `x` or `y` start with a leading `0`, all the numbers will be padded
to have equal length. Negative numbers and backwards iteration work too.

```js
/^-?\d+\.\.-?\d+(\.\.-?\d+)?$/
// {x..y[..incr]}
```

An alphabetic sequence from `x` to `y` inclusive, with optional increment.
`x` and `y` must be exactly one character, and if given, `incr` must be a
number.

For compatibility reasons, the string `${` is not eligible for brace expansion.

## Installation

With [npm](https://npmjs.org) do:

```bash
npm install brace-expansion
```

## Contributors

- [Julian Gruber](https://github.com/juliangruber)
- [Isaac Z. Schlueter](https://github.com/isaacs)

## Sponsors

This module is proudly supported by my [Sponsors](https://github.com/juliangruber/sponsors)!

Do you want to support modules like this to improve their quality, stability and weigh in on new features? Then please consider donating to my [Patreon](https://www.patreon.com/juliangruber). Not sure how much of my modules you're using? Try [feross/thanks](https://github.com/feross/thanks)!

## License

(MIT)

Copyright (c) 2013 Julian Gruber &lt;julian@juliangruber.com&gt;

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



# [Jump to node_modules/fs.realpath](node_modules/fs.realpath)

# fs.realpath

A backwards-compatible fs.realpath for Node v6 and above

In Node v6, the JavaScript implementation of fs.realpath was replaced
with a faster (but less resilient) native implementation.  That raises
new and platform-specific errors and cannot handle long or excessively
symlink-looping paths.

This module handles those cases by detecting the new errors and
falling back to the JavaScript implementation.  On versions of Node
prior to v6, it has no effect.

## USAGE

```js
var rp = require('fs.realpath')

// async version
rp.realpath(someLongAndLoopingPath, function (er, real) {
  // the ELOOP was handled, but it was a bit slower
})

// sync version
var real = rp.realpathSync(someLongAndLoopingPath)

// monkeypatch at your own risk!
// This replaces the fs.realpath/fs.realpathSync builtins
rp.monkeypatch()

// un-do the monkeypatching
rp.unmonkeypatch()
```



# [Jump to node_modules/glob](node_modules/glob)

## 7.0

- Raise error if `options.cwd` is specified, and not a directory

## 6.0

- Remove comment and negation pattern support
- Ignore patterns are always in `dot:true` mode

## 5.0

- Deprecate comment and negation patterns
- Fix regression in `mark` and `nodir` options from making all cache
  keys absolute path.
- Abort if `fs.readdir` returns an error that's unexpected
- Don't emit `match` events for ignored items
- Treat ENOTSUP like ENOTDIR in readdir

## 4.5

- Add `options.follow` to always follow directory symlinks in globstar
- Add `options.realpath` to call `fs.realpath` on all results
- Always cache based on absolute path

## 4.4

- Add `options.ignore`
- Fix handling of broken symlinks

## 4.3

- Bump minimatch to 2.x
- Pass all tests on Windows

## 4.2

- Add `glob.hasMagic` function
- Add `options.nodir` flag

## 4.1

- Refactor sync and async implementations for performance
- Throw if callback provided to sync glob function
- Treat symbolic links in globstar results the same as Bash 4.3

## 4.0

- Use `^` for dependency versions (bumped major because this breaks
  older npm versions)
- Ensure callbacks are only ever called once
- switch to ISC license

## 3.x

- Rewrite in JavaScript
- Add support for setting root, cwd, and windows support
- Cache many fs calls
- Add globstar support
- emit match events

## 2.x

- Use `glob.h` and `fnmatch.h` from NetBSD

## 1.x

- `glob.h` static binding.



# [Jump to node_modules/glob](node_modules/glob)

# Glob

Match files using the patterns the shell uses, like stars and stuff.

[![Build Status](https://travis-ci.org/isaacs/node-glob.svg?branch=master)](https://travis-ci.org/isaacs/node-glob/) [![Build Status](https://ci.appveyor.com/api/projects/status/kd7f3yftf7unxlsx?svg=true)](https://ci.appveyor.com/project/isaacs/node-glob) [![Coverage Status](https://coveralls.io/repos/isaacs/node-glob/badge.svg?branch=master&service=github)](https://coveralls.io/github/isaacs/node-glob?branch=master)

This is a glob implementation in JavaScript.  It uses the `minimatch`
library to do its matching.

![](logo/glob.png)

## Usage

Install with npm

```
npm i glob
```

```javascript
var glob = require("glob")

// options is optional
glob("**/*.js", options, function (er, files) {
  // files is an array of filenames.
  // If the `nonull` option is set, and nothing
  // was found, then files is ["**/*.js"]
  // er is an error object or null.
})
```

## Glob Primer

"Globs" are the patterns you type when you do stuff like `ls *.js` on
the command line, or put `build/*` in a `.gitignore` file.

Before parsing the path part patterns, braced sections are expanded
into a set.  Braced sections start with `{` and end with `}`, with any
number of comma-delimited sections within.  Braced sections may contain
slash characters, so `a{/b/c,bcd}` would expand into `a/b/c` and `abcd`.

The following characters have special magic meaning when used in a
path portion:

* `*` Matches 0 or more characters in a single path portion
* `?` Matches 1 character
* `[...]` Matches a range of characters, similar to a RegExp range.
  If the first character of the range is `!` or `^` then it matches
  any character not in the range.
* `!(pattern|pattern|pattern)` Matches anything that does not match
  any of the patterns provided.
* `?(pattern|pattern|pattern)` Matches zero or one occurrence of the
  patterns provided.
* `+(pattern|pattern|pattern)` Matches one or more occurrences of the
  patterns provided.
* `*(a|b|c)` Matches zero or more occurrences of the patterns provided
* `@(pattern|pat*|pat?erN)` Matches exactly one of the patterns
  provided
* `**` If a "globstar" is alone in a path portion, then it matches
  zero or more directories and subdirectories searching for matches.
  It does not crawl symlinked directories.

### Dots

If a file or directory path portion has a `.` as the first character,
then it will not match any glob pattern unless that pattern's
corresponding path part also has a `.` as its first character.

For example, the pattern `a/.*/c` would match the file at `a/.b/c`.
However the pattern `a/*/c` would not, because `*` does not start with
a dot character.

You can make glob treat dots as normal characters by setting
`dot:true` in the options.

### Basename Matching

If you set `matchBase:true` in the options, and the pattern has no
slashes in it, then it will seek for any file anywhere in the tree
with a matching basename.  For example, `*.js` would match
`test/simple/basic.js`.

### Empty Sets

If no matching files are found, then an empty array is returned.  This
differs from the shell, where the pattern itself is returned.  For
example:

    $ echo a*s*d*f
    a*s*d*f

To get the bash-style behavior, set the `nonull:true` in the options.

### See Also:

* `man sh`
* `man bash` (Search for "Pattern Matching")
* `man 3 fnmatch`
* `man 5 gitignore`
* [minimatch documentation](https://github.com/isaacs/minimatch)

## glob.hasMagic(pattern, [options])

Returns `true` if there are any special characters in the pattern, and
`false` otherwise.

Note that the options affect the results.  If `noext:true` is set in
the options object, then `+(a|b)` will not be considered a magic
pattern.  If the pattern has a brace expansion, like `a/{b/c,x/y}`
then that is considered magical, unless `nobrace:true` is set in the
options.

## glob(pattern, [options], cb)

* `pattern` `{String}` Pattern to be matched
* `options` `{Object}`
* `cb` `{Function}`
  * `err` `{Error | null}`
  * `matches` `{Array<String>}` filenames found matching the pattern

Perform an asynchronous glob search.

## glob.sync(pattern, [options])

* `pattern` `{String}` Pattern to be matched
* `options` `{Object}`
* return: `{Array<String>}` filenames found matching the pattern

Perform a synchronous glob search.

## Class: glob.Glob

Create a Glob object by instantiating the `glob.Glob` class.

```javascript
var Glob = require("glob").Glob
var mg = new Glob(pattern, options, cb)
```

It's an EventEmitter, and starts walking the filesystem to find matches
immediately.

### new glob.Glob(pattern, [options], [cb])

* `pattern` `{String}` pattern to search for
* `options` `{Object}`
* `cb` `{Function}` Called when an error occurs, or matches are found
  * `err` `{Error | null}`
  * `matches` `{Array<String>}` filenames found matching the pattern

Note that if the `sync` flag is set in the options, then matches will
be immediately available on the `g.found` member.

### Properties

* `minimatch` The minimatch object that the glob uses.
* `options` The options object passed in.
* `aborted` Boolean which is set to true when calling `abort()`.  There
  is no way at this time to continue a glob search after aborting, but
  you can re-use the statCache to avoid having to duplicate syscalls.
* `cache` Convenience object.  Each field has the following possible
  values:
  * `false` - Path does not exist
  * `true` - Path exists
  * `'FILE'` - Path exists, and is not a directory
  * `'DIR'` - Path exists, and is a directory
  * `[file, entries, ...]` - Path exists, is a directory, and the
    array value is the results of `fs.readdir`
* `statCache` Cache of `fs.stat` results, to prevent statting the same
  path multiple times.
* `symlinks` A record of which paths are symbolic links, which is
  relevant in resolving `**` patterns.
* `realpathCache` An optional object which is passed to `fs.realpath`
  to minimize unnecessary syscalls.  It is stored on the instantiated
  Glob object, and may be re-used.

### Events

* `end` When the matching is finished, this is emitted with all the
  matches found.  If the `nonull` option is set, and no match was found,
  then the `matches` list contains the original pattern.  The matches
  are sorted, unless the `nosort` flag is set.
* `match` Every time a match is found, this is emitted with the specific
  thing that matched. It is not deduplicated or resolved to a realpath.
* `error` Emitted when an unexpected error is encountered, or whenever
  any fs error occurs if `options.strict` is set.
* `abort` When `abort()` is called, this event is raised.

### Methods

* `pause` Temporarily stop the search
* `resume` Resume the search
* `abort` Stop the search forever

### Options

All the options that can be passed to Minimatch can also be passed to
Glob to change pattern matching behavior.  Also, some have been added,
or have glob-specific ramifications.

All options are false by default, unless otherwise noted.

All options are added to the Glob object, as well.

If you are running many `glob` operations, you can pass a Glob object
as the `options` argument to a subsequent operation to shortcut some
`stat` and `readdir` calls.  At the very least, you may pass in shared
`symlinks`, `statCache`, `realpathCache`, and `cache` options, so that
parallel glob operations will be sped up by sharing information about
the filesystem.

* `cwd` The current working directory in which to search.  Defaults
  to `process.cwd()`.
* `root` The place where patterns starting with `/` will be mounted
  onto.  Defaults to `path.resolve(options.cwd, "/")` (`/` on Unix
  systems, and `C:\` or some such on Windows.)
* `dot` Include `.dot` files in normal matches and `globstar` matches.
  Note that an explicit dot in a portion of the pattern will always
  match dot files.
* `nomount` By default, a pattern starting with a forward-slash will be
  "mounted" onto the root setting, so that a valid filesystem path is
  returned.  Set this flag to disable that behavior.
* `mark` Add a `/` character to directory matches.  Note that this
  requires additional stat calls.
* `nosort` Don't sort the results.
* `stat` Set to true to stat *all* results.  This reduces performance
  somewhat, and is completely unnecessary, unless `readdir` is presumed
  to be an untrustworthy indicator of file existence.
* `silent` When an unusual error is encountered when attempting to
  read a directory, a warning will be printed to stderr.  Set the
  `silent` option to true to suppress these warnings.
* `strict` When an unusual error is encountered when attempting to
  read a directory, the process will just continue on in search of
  other matches.  Set the `strict` option to raise an error in these
  cases.
* `cache` See `cache` property above.  Pass in a previously generated
  cache object to save some fs calls.
* `statCache` A cache of results of filesystem information, to prevent
  unnecessary stat calls.  While it should not normally be necessary
  to set this, you may pass the statCache from one glob() call to the
  options object of another, if you know that the filesystem will not
  change between calls.  (See "Race Conditions" below.)
* `symlinks` A cache of known symbolic links.  You may pass in a
  previously generated `symlinks` object to save `lstat` calls when
  resolving `**` matches.
* `sync` DEPRECATED: use `glob.sync(pattern, opts)` instead.
* `nounique` In some cases, brace-expanded patterns can result in the
  same file showing up multiple times in the result set.  By default,
  this implementation prevents duplicates in the result set.  Set this
  flag to disable that behavior.
* `nonull` Set to never return an empty set, instead returning a set
  containing the pattern itself.  This is the default in glob(3).
* `debug` Set to enable debug logging in minimatch and glob.
* `nobrace` Do not expand `{a,b}` and `{1..3}` brace sets.
* `noglobstar` Do not match `**` against multiple filenames.  (Ie,
  treat it as a normal `*` instead.)
* `noext` Do not match `+(a|b)` "extglob" patterns.
* `nocase` Perform a case-insensitive match.  Note: on
  case-insensitive filesystems, non-magic patterns will match by
  default, since `stat` and `readdir` will not raise errors.
* `matchBase` Perform a basename-only match if the pattern does not
  contain any slash characters.  That is, `*.js` would be treated as
  equivalent to `**/*.js`, matching all js files in all directories.
* `nodir` Do not match directories, only files.  (Note: to match
  *only* directories, simply put a `/` at the end of the pattern.)
* `ignore` Add a pattern or an array of glob patterns to exclude matches.
  Note: `ignore` patterns are *always* in `dot:true` mode, regardless
  of any other settings.
* `follow` Follow symlinked directories when expanding `**` patterns.
  Note that this can result in a lot of duplicate references in the
  presence of cyclic links.
* `realpath` Set to true to call `fs.realpath` on all of the results.
  In the case of a symlink that cannot be resolved, the full absolute
  path to the matched entry is returned (though it will usually be a
  broken symlink)
* `absolute` Set to true to always receive absolute paths for matched
  files.  Unlike `realpath`, this also affects the values returned in
  the `match` event.

## Comparisons to other fnmatch/glob implementations

While strict compliance with the existing standards is a worthwhile
goal, some discrepancies exist between node-glob and other
implementations, and are intentional.

The double-star character `**` is supported by default, unless the
`noglobstar` flag is set.  This is supported in the manner of bsdglob
and bash 4.3, where `**` only has special significance if it is the only
thing in a path part.  That is, `a/**/b` will match `a/x/y/b`, but
`a/**b` will not.

Note that symlinked directories are not crawled as part of a `**`,
though their contents may match against subsequent portions of the
pattern.  This prevents infinite loops and duplicates and the like.

If an escaped pattern has no matches, and the `nonull` flag is set,
then glob returns the pattern as-provided, rather than
interpreting the character escapes.  For example,
`glob.match([], "\\*a\\?")` will return `"\\*a\\?"` rather than
`"*a?"`.  This is akin to setting the `nullglob` option in bash, except
that it does not resolve escaped pattern characters.

If brace expansion is not disabled, then it is performed before any
other interpretation of the glob pattern.  Thus, a pattern like
`+(a|{b),c)}`, which would not be valid in bash or zsh, is expanded
**first** into the set of `+(a|b)` and `+(a|c)`, and those patterns are
checked for validity.  Since those two are valid, matching proceeds.

### Comments and Negation

Previously, this module let you mark a pattern as a "comment" if it
started with a `#` character, or a "negated" pattern if it started
with a `!` character.

These options were deprecated in version 5, and removed in version 6.

To specify things that should not match, use the `ignore` option.

## Windows

**Please only use forward-slashes in glob expressions.**

Though windows uses either `/` or `\` as its path separator, only `/`
characters are used by this glob implementation.  You must use
forward-slashes **only** in glob expressions.  Back-slashes will always
be interpreted as escape characters, not path separators.

Results from absolute patterns such as `/foo/*` are mounted onto the
root setting using `path.join`.  On windows, this will by default result
in `/foo/*` matching `C:\foo\bar.txt`.

## Race Conditions

Glob searching, by its very nature, is susceptible to race conditions,
since it relies on directory walking and such.

As a result, it is possible that a file that exists when glob looks for
it may have been deleted or modified by the time it returns the result.

As part of its internal implementation, this program caches all stat
and readdir calls that it makes, in order to cut down on system
overhead.  However, this also makes it even more susceptible to races,
especially if the cache or statCache objects are reused between glob
calls.

Users are thus advised not to use a glob result as a guarantee of
filesystem state in the face of rapid changes.  For the vast majority
of operations, this is never a problem.

## Glob Logo
Glob's logo was created by [Tanya Brassie](http://tanyabrassie.com/). Logo files can be found [here](https://github.com/isaacs/node-glob/tree/master/logo).

The logo is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).

## Contributing

Any change to behavior (including bugfixes) must come with a test.

Patches that fail tests or reduce performance will be rejected.

```
# to run tests
npm test

# to re-generate test fixtures
npm run test-regen

# to benchmark against bash/zsh
npm run bench

# to profile javascript
npm run prof
```

![](oh-my-glob.gif)



# [Jump to node_modules/inflight](node_modules/inflight)

# inflight

Add callbacks to requests in flight to avoid async duplication

## USAGE

```javascript
var inflight = require('inflight')

// some request that does some stuff
function req(key, callback) {
  // key is any random string.  like a url or filename or whatever.
  //
  // will return either a falsey value, indicating that the
  // request for this key is already in flight, or a new callback
  // which when called will call all callbacks passed to inflightk
  // with the same key
  callback = inflight(key, callback)

  // If we got a falsey value back, then there's already a req going
  if (!callback) return

  // this is where you'd fetch the url or whatever
  // callback is also once()-ified, so it can safely be assigned
  // to multiple events etc.  First call wins.
  setTimeout(function() {
    callback(null, key)
  }, 100)
}

// only assigns a single setTimeout
// when it dings, all cbs get called
req('foo', cb1)
req('foo', cb2)
req('foo', cb3)
req('foo', cb4)
```



# [Jump to node_modules/inherits](node_modules/inherits)

Browser-friendly inheritance fully compatible with standard node.js
[inherits](http://nodejs.org/api/util.html#util_util_inherits_constructor_superconstructor).

This package exports standard `inherits` from node.js `util` module in
node environment, but also provides alternative browser-friendly
implementation through [browser
field](https://gist.github.com/shtylman/4339901). Alternative
implementation is a literal copy of standard one located in standalone
module to avoid requiring of `util`. It also has a shim for old
browsers with no `Object.create` support.

While keeping you sure you are using standard `inherits`
implementation in node.js environment, it allows bundlers such as
[browserify](https://github.com/substack/node-browserify) to not
include full `util` package to your client code if all you need is
just `inherits` function. It worth, because browser shim for `util`
package is large and `inherits` is often the single function you need
from it.

It's recommended to use this package instead of
`require('util').inherits` for any code that has chances to be used
not only in node.js but in browser too.

## usage

```js
var inherits = require('inherits');
// then use exactly as the standard one
```

## note on version ~1.0

Version ~1.0 had completely different motivation and is not compatible
neither with 2.0 nor with standard node.js `inherits`.

If you are using version ~1.0 and planning to switch to ~2.0, be
careful:

* new version uses `super_` instead of `super` for referencing
  superclass
* new version overwrites current prototype while old one preserves any
  existing fields on it



# [Jump to node_modules/minimatch](node_modules/minimatch)

# minimatch

A minimal matching utility.

[![Build Status](https://secure.travis-ci.org/isaacs/minimatch.svg)](http://travis-ci.org/isaacs/minimatch)


This is the matching library used internally by npm.

It works by converting glob expressions into JavaScript `RegExp`
objects.

## Usage

```javascript
var minimatch = require("minimatch")

minimatch("bar.foo", "*.foo") // true!
minimatch("bar.foo", "*.bar") // false!
minimatch("bar.foo", "*.+(bar|foo)", { debug: true }) // true, and noisy!
```

## Features

Supports these glob features:

* Brace Expansion
* Extended glob matching
* "Globstar" `**` matching

See:

* `man sh`
* `man bash`
* `man 3 fnmatch`
* `man 5 gitignore`

## Minimatch Class

Create a minimatch object by instantiating the `minimatch.Minimatch` class.

```javascript
var Minimatch = require("minimatch").Minimatch
var mm = new Minimatch(pattern, options)
```

### Properties

* `pattern` The original pattern the minimatch object represents.
* `options` The options supplied to the constructor.
* `set` A 2-dimensional array of regexp or string expressions.
  Each row in the
  array corresponds to a brace-expanded pattern.  Each item in the row
  corresponds to a single path-part.  For example, the pattern
  `{a,b/c}/d` would expand to a set of patterns like:

        [ [ a, d ]
        , [ b, c, d ] ]

    If a portion of the pattern doesn't have any "magic" in it
    (that is, it's something like `"foo"` rather than `fo*o?`), then it
    will be left as a string rather than converted to a regular
    expression.

* `regexp` Created by the `makeRe` method.  A single regular expression
  expressing the entire pattern.  This is useful in cases where you wish
  to use the pattern somewhat like `fnmatch(3)` with `FNM_PATH` enabled.
* `negate` True if the pattern is negated.
* `comment` True if the pattern is a comment.
* `empty` True if the pattern is `""`.

### Methods

* `makeRe` Generate the `regexp` member if necessary, and return it.
  Will return `false` if the pattern is invalid.
* `match(fname)` Return true if the filename matches the pattern, or
  false otherwise.
* `matchOne(fileArray, patternArray, partial)` Take a `/`-split
  filename, and match it against a single row in the `regExpSet`.  This
  method is mainly for internal use, but is exposed so that it can be
  used by a glob-walker that needs to avoid excessive filesystem calls.

All other methods are internal, and will be called as necessary.

### minimatch(path, pattern, options)

Main export.  Tests a path against the pattern using the options.

```javascript
var isJS = minimatch(file, "*.js", { matchBase: true })
```

### minimatch.filter(pattern, options)

Returns a function that tests its
supplied argument, suitable for use with `Array.filter`.  Example:

```javascript
var javascripts = fileList.filter(minimatch.filter("*.js", {matchBase: true}))
```

### minimatch.match(list, pattern, options)

Match against the list of
files, in the style of fnmatch or glob.  If nothing is matched, and
options.nonull is set, then return a list containing the pattern itself.

```javascript
var javascripts = minimatch.match(fileList, "*.js", {matchBase: true}))
```

### minimatch.makeRe(pattern, options)

Make a regular expression object from the pattern.

## Options

All options are `false` by default.

### debug

Dump a ton of stuff to stderr.

### nobrace

Do not expand `{a,b}` and `{1..3}` brace sets.

### noglobstar

Disable `**` matching against multiple folder names.

### dot

Allow patterns to match filenames starting with a period, even if
the pattern does not explicitly have a period in that spot.

Note that by default, `a/**/b` will **not** match `a/.d/b`, unless `dot`
is set.

### noext

Disable "extglob" style patterns like `+(a|b)`.

### nocase

Perform a case-insensitive match.

### nonull

When a match is not found by `minimatch.match`, return a list containing
the pattern itself if this option is set.  When not set, an empty list
is returned if there are no matches.

### matchBase

If set, then patterns without slashes will be matched
against the basename of the path if it contains slashes.  For example,
`a?b` would match the path `/xyz/123/acb`, but not `/xyz/acb/123`.

### nocomment

Suppress the behavior of treating `#` at the start of a pattern as a
comment.

### nonegate

Suppress the behavior of treating a leading `!` character as negation.

### flipNegate

Returns from negate expressions the same as if they were not negated.
(Ie, true on a hit, false on a miss.)


## Comparisons to other fnmatch/glob implementations

While strict compliance with the existing standards is a worthwhile
goal, some discrepancies exist between minimatch and other
implementations, and are intentional.

If the pattern starts with a `!` character, then it is negated.  Set the
`nonegate` flag to suppress this behavior, and treat leading `!`
characters normally.  This is perhaps relevant if you wish to start the
pattern with a negative extglob pattern like `!(a|B)`.  Multiple `!`
characters at the start of a pattern will negate the pattern multiple
times.

If a pattern starts with `#`, then it is treated as a comment, and
will not match anything.  Use `\#` to match a literal `#` at the
start of a line, or set the `nocomment` flag to suppress this behavior.

The double-star character `**` is supported by default, unless the
`noglobstar` flag is set.  This is supported in the manner of bsdglob
and bash 4.1, where `**` only has special significance if it is the only
thing in a path part.  That is, `a/**/b` will match `a/x/y/b`, but
`a/**b` will not.

If an escaped pattern has no matches, and the `nonull` flag is set,
then minimatch.match returns the pattern as-provided, rather than
interpreting the character escapes.  For example,
`minimatch.match([], "\\*a\\?")` will return `"\\*a\\?"` rather than
`"*a?"`.  This is akin to setting the `nullglob` option in bash, except
that it does not resolve escaped pattern characters.

If brace expansion is not disabled, then it is performed before any
other interpretation of the glob pattern.  Thus, a pattern like
`+(a|{b),c)}`, which would not be valid in bash or zsh, is expanded
**first** into the set of `+(a|b)` and `+(a|c)`, and those patterns are
checked for validity.  Since those two are valid, matching proceeds.



# [Jump to node_modules/once](node_modules/once)

# once

Only call a function once.

## usage

```javascript
var once = require('once')

function load (file, cb) {
  cb = once(cb)
  loader.load('file')
  loader.once('load', cb)
  loader.once('error', cb)
}
```

Or add to the Function.prototype in a responsible way:

```javascript
// only has to be done once
require('once').proto()

function load (file, cb) {
  cb = cb.once()
  loader.load('file')
  loader.once('load', cb)
  loader.once('error', cb)
}
```

Ironically, the prototype feature makes this module twice as
complicated as necessary.

To check whether you function has been called, use `fn.called`. Once the
function is called for the first time the return value of the original
function is saved in `fn.value` and subsequent calls will continue to
return this value.

```javascript
var once = require('once')

function load (cb) {
  cb = once(cb)
  var stream = createStream()
  stream.once('data', cb)
  stream.once('end', function () {
    if (!cb.called) cb(new Error('not found'))
  })
}
```

## `once.strict(func)`

Throw an error if the function is called twice.

Some functions are expected to be called only once. Using `once` for them would
potentially hide logical errors.

In the example below, the `greet` function has to call the callback only once:

```javascript
function greet (name, cb) {
  // return is missing from the if statement
  // when no name is passed, the callback is called twice
  if (!name) cb('Hello anonymous')
  cb('Hello ' + name)
}

function log (msg) {
  console.log(msg)
}

// this will print 'Hello anonymous' but the logical error will be missed
greet(null, once(msg))

// once.strict will print 'Hello anonymous' and throw an error when the callback will be called the second time
greet(null, once.strict(msg))
```



# [Jump to node_modules/path-is-absolute](node_modules/path-is-absolute)

# path-is-absolute [![Build Status](https://travis-ci.org/sindresorhus/path-is-absolute.svg?branch=master)](https://travis-ci.org/sindresorhus/path-is-absolute)

> Node.js 0.12 [`path.isAbsolute()`](http://nodejs.org/api/path.html#path_path_isabsolute_path) [ponyfill](https://ponyfill.com)


## Install

```
$ npm install --save path-is-absolute
```


## Usage

```js
const pathIsAbsolute = require('path-is-absolute');

// Running on Linux
pathIsAbsolute('/home/foo');
//=> true
pathIsAbsolute('C:/Users/foo');
//=> false

// Running on Windows
pathIsAbsolute('C:/Users/foo');
//=> true
pathIsAbsolute('/home/foo');
//=> false

// Running on any OS
pathIsAbsolute.posix('/home/foo');
//=> true
pathIsAbsolute.posix('C:/Users/foo');
//=> false
pathIsAbsolute.win32('C:/Users/foo');
//=> true
pathIsAbsolute.win32('/home/foo');
//=> false
```


## API

See the [`path.isAbsolute()` docs](http://nodejs.org/api/path.html#path_path_isabsolute_path).

### pathIsAbsolute(path)

### pathIsAbsolute.posix(path)

POSIX specific version.

### pathIsAbsolute.win32(path)

Windows specific version.


## License

MIT © [Sindre Sorhus](https://sindresorhus.com)



# [Jump to node_modules/wrappy](node_modules/wrappy)

# wrappy

Callback wrapping utility

## USAGE

```javascript
var wrappy = require("wrappy")

// var wrapper = wrappy(wrapperFunction)

// make sure a cb is called only once
// See also: http://npm.im/once for this specific use case
var once = wrappy(function (cb) {
  var called = false
  return function () {
    if (called) return
    called = true
    return cb.apply(this, arguments)
  }
})

function printBoo () {
  console.log('boo')
}
// has some rando property
printBoo.iAmBooPrinter = true

var onlyPrintOnce = once(printBoo)

onlyPrintOnce() // prints 'boo'
onlyPrintOnce() // does nothing

// random property is retained!
assert.equal(onlyPrintOnce.iAmBooPrinter, true)
```


