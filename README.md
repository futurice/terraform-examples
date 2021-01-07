![Hero](_header_/hero.png)
 
# Repository containing various Terraform code
 
Lots of Terraform recipes for doing things, aimed for copy and pasting into projects.
 
- [AWS Examples](#aws-examples)
- [Azure Examples](#azure-examples)
- [Google Cloud Platform Examples](#google-cloud-platform-examples)
 
# Knowledge-as-code
 
Terraform is an ideal knowledge transfer tool that can communicate the minutea of using certain technology combinations. We use this at [Futurice](https://futurice.com?source=terraform-examples) to disseminate hard won learnings across projects and industries, increasing the development velocity for all of our clients.
 
# Read more about specific projects
 
A few of the recipes have associated blog posts.
 
- [Terraform Recipe for WordPress on Fargate](https://futurice.com/blog/terraform-recipe-wordpress-fargate)
- [OpenResty: a Swiss Army Proxy for Serverless; WAL, Slack, Zapier and Auth](https://futurice.com/blog/openresty-a-swiss-army-proxy-for-serverless)
- [Low cost Friends and Family Minecraft server](https://www.futurice.com/blog/friends-and-family-minecraft-server-terraform-recipe)
- [Minimalist BeyondCorp style Identity Aware Proxy for Cloud Run](https://futurice.com/blog/identity-aware-proxy-for-google-cloud-run)
- [Serverless Camunda Business Workflow Engine on Cloud Run](https://www.futurice.com/blog/serverless-camunda-terraform-recipe-using-cloud-run-and-cloud-sql)
- [A Detailed Look at Camunda BPMN Application Development](https://futurice.com/blog/a-detailed-look-at-camunda-bpmn-application-development)
- [Exporting Bigquery to Cloud Memorystore](https://www.futurice.com/blog/bigquery-to-memorystore)
 
# Contribution
 
External contributions welcome! All that we ask is that the recipe is interesting, and that it worked at some point. There is no expectation of maintenance (maintained projects should probably have their own repository). No two projects are alike, and so, we expect most uses of this repository to require customization.
 
To regenerate the readme, run `npm run readme`

## Directory layout

- [aws](aws)
  - [aws/aws_domain_redirect](aws/aws_domain_redirect)
  - [aws/aws_ec2_ebs_docker_host](aws/aws_ec2_ebs_docker_host)
    - resource aws_instance
    - resource aws_key_pair
    - resource aws_security_group
    - resource aws_security_group_rule
    - resource aws_volume_attachment
    - resource null_resource
  - [aws/aws_lambda_api](aws/aws_lambda_api)
    - resource aws_acm_certificate
    - resource aws_acm_certificate_validation
    - resource aws_api_gateway_base_path_mapping
    - resource aws_api_gateway_deployment
    - resource aws_api_gateway_domain_name
    - resource aws_api_gateway_integration
    - resource aws_api_gateway_integration_response
    - resource aws_api_gateway_method
    - resource aws_api_gateway_method_response
    - resource aws_api_gateway_method_settings
    - resource aws_api_gateway_resource
    - resource aws_api_gateway_rest_api
    - resource aws_api_gateway_stage
    - resource aws_iam_policy
    - resource aws_iam_role
    - resource aws_iam_role_policy_attachment
    - resource aws_lambda_function
    - resource aws_lambda_permission
    - resource aws_route53_record
  - [aws/aws_lambda_cronjob](aws/aws_lambda_cronjob)
    - resource aws_cloudwatch_event_rule
    - resource aws_cloudwatch_event_target
    - resource aws_iam_policy
    - resource aws_iam_role
    - resource aws_iam_role_policy_attachment
    - resource aws_lambda_function
    - resource aws_lambda_permission
  - [aws/aws_mailgun_domain](aws/aws_mailgun_domain)
    - resource aws_route53_record
    - resource mailgun_domain
  - [aws/aws_reverse_proxy](aws/aws_reverse_proxy)
    - resource aws_acm_certificate
    - resource aws_acm_certificate_validation
    - resource aws_cloudfront_distribution
    - resource aws_iam_policy
    - resource aws_iam_role
    - resource aws_iam_role_policy_attachment
    - resource aws_lambda_function
    - resource aws_route53_record
  - [aws/aws_static_site](aws/aws_static_site)
    - resource aws_s3_bucket
    - resource aws_s3_bucket_policy
    - resource random_string
  - [aws/aws_vpc_msk](aws/aws_vpc_msk)
    - resource aws_acmpca_certificate_authority
    - resource aws_cloudwatch_log_group
    - resource aws_eip
    - resource aws_iam_instance_profile
    - resource aws_iam_role
    - resource aws_iam_role_policy_attachment
    - resource aws_instance
    - resource aws_internet_gateway
    - resource aws_key_pair
    - resource aws_kms_alias
    - resource aws_kms_key
    - resource aws_msk_cluster
    - resource aws_msk_configuration
    - resource aws_nat_gateway
    - resource aws_route_table
    - resource aws_route_table_association
    - resource aws_security_group
    - resource aws_subnet
    - resource aws_vpc
    - resource random_id
    - resource random_uuid
  - [aws/static_website_ssl_cloudfront_private_s3](aws/static_website_ssl_cloudfront_private_s3)
    - resource aws_cloudfront_distribution
    - resource aws_cloudfront_origin_access_identity
    - resource aws_route53_record
    - resource aws_s3_bucket
    - resource aws_s3_bucket_policy
    - resource aws_s3_bucket_public_access_block
  - [aws/wordpress_fargate](aws/wordpress_fargate)
    - resource aws_appautoscaling_policy
    - resource aws_appautoscaling_target
    - resource aws_cloudfront_distribution
    - resource aws_cloudwatch_log_group
    - resource aws_cloudwatch_metric_alarm
    - resource aws_db_subnet_group
    - resource aws_ecs_cluster
    - resource aws_ecs_service
    - resource aws_ecs_task_definition
    - resource aws_efs_file_system
    - resource aws_efs_mount_target
    - resource aws_iam_policy
    - resource aws_iam_role
    - resource aws_iam_role_policy_attachment
    - resource aws_lb_listener_rule
    - resource aws_lb_target_group
    - resource aws_rds_cluster
    - resource aws_route53_record
    - resource aws_security_group
    - resource aws_ssm_parameter
    - resource random_string
- [azure](azure)
  - [azure/azure_linux_docker_app_service](azure/azure_linux_docker_app_service)
    - resource azurerm_app_service
    - resource azurerm_app_service_plan
    - resource azurerm_app_service_slot
    - resource azurerm_application_insights
    - resource azurerm_application_insights_web_test
    - resource azurerm_container_registry
    - resource azurerm_key_vault
    - resource azurerm_key_vault_access_policy
    - resource azurerm_key_vault_secret
    - resource azurerm_monitor_action_group
    - resource azurerm_monitor_metric_alert
    - resource azurerm_monitor_scheduled_query_rules_alert
    - resource azurerm_role_assignment
    - resource random_string
  - [azure/layers](azure/layers)
    - resource azurerm_resource_group
    - resource azurerm_storage_account
    - resource azurerm_storage_blob
    - resource azurerm_storage_container
    - resource azurerm_subnet
    - resource azurerm_virtual_network
    - resource null_resource
- [generic](generic)
  - [generic/docker_compose_host](generic/docker_compose_host)
    - resource null_resource
- [google_cloud](google_cloud)
  - [google_cloud/camunda-secure](google_cloud/camunda-secure)
    - resource google_cloud_run_service
    - resource google_project_iam_member
    - resource google_service_account
    - resource google_sql_database
    - resource google_sql_database_instance
    - resource google_sql_user
    - resource local_file
    - resource null_resource
  - [google_cloud/camunda](google_cloud/camunda)
    - resource google_cloud_run_service
    - resource google_cloud_run_service_iam_policy
    - resource google_project_iam_member
    - resource google_service_account
    - resource google_sql_database
    - resource google_sql_database_instance
    - resource google_sql_user
    - resource local_file
    - resource null_resource
  - [google_cloud/CQRS_bigquery_memorystore](google_cloud/CQRS_bigquery_memorystore)
    - resource google_storage_bucket
    - resource google_storage_bucket_object
  - [google_cloud/minecraft](google_cloud/minecraft)
    - resource google_compute_address
    - resource google_compute_disk
    - resource google_compute_firewall
    - resource google_compute_instance
    - resource google_compute_instance_iam_member
    - resource google_compute_network
    - resource google_project_iam_custom_role
    - resource google_project_iam_member
    - resource google_service_account
  - [google_cloud/oathkeeper](google_cloud/oathkeeper)
    - resource google_cloud_run_service
    - resource google_cloud_run_service_iam_policy
    - resource google_service_account
    - resource google_storage_bucket
    - resource google_storage_bucket_iam_member
    - resource google_storage_bucket_object
    - resource local_file
    - resource null_resource
  - [google_cloud/openresty-beyondcorp](google_cloud/openresty-beyondcorp)
    - resource google_cloud_run_service
    - resource google_cloud_run_service_iam_policy
    - resource google_project_iam_member
    - resource google_pubsub_subscription
    - resource google_pubsub_topic
    - resource google_service_account
    - resource local_file
    - resource null_resource
    - resource template_dir


# [aws](aws)
# AWS Examples


# [aws/aws_domain_redirect](aws/aws_domain_redirect)
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



# [aws/aws_ec2_ebs_docker_host](aws/aws_ec2_ebs_docker_host)
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



# [aws/aws_lambda_api](aws/aws_lambda_api)
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



# [aws/aws_lambda_cronjob](aws/aws_lambda_cronjob)
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



# [aws/aws_mailgun_domain](aws/aws_mailgun_domain)
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



# [aws/aws_reverse_proxy](aws/aws_reverse_proxy)
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



# [aws/aws_static_site](aws/aws_static_site)
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



# [aws/aws_vpc_msk](aws/aws_vpc_msk)
# tf-msk
Terraform deployment of an AWS VPC, MSK Cluster, (optional) ACM-PCA &amp; MSK Client

[![Infrastructure Tests](aws/aws_vpc_msk/https://www.bridgecrew.cloud/badges/github/troydieter/tf-msk/general)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=troydieter%2Ftf-msk&benchmark=INFRASTRUCTURE+SECURITY)
<br>
[![Infrastructure Tests](aws/aws_vpc_msk/https://www.bridgecrew.cloud/badges/github/troydieter/tf-msk/cis_aws)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=troydieter%2Ftf-msk&benchmark=CIS+AWS+V1.2)
<br>
[![Infrastructure Tests](aws/aws_vpc_msk/https://www.bridgecrew.cloud/badges/github/troydieter/tf-msk/hipaa)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=troydieter%2Ftf-msk&benchmark=HIPAA)


# [aws/static_website_ssl_cloudfront_private_s3](aws/static_website_ssl_cloudfront_private_s3)
# Static website hosted using S3 and cloudfront with SSL support

Hosting static website using S3 is a very cost effective approach. Since, S3 website does not support SSL certificate, we use cloudfront for the same. In this example, we host the contents in a private S3 bucket which is used as the origin for cloudfront. We use cloudfront Origin-Access-Identity to access the private content from S3.

## Architecture

![Architecture](aws/static_website_ssl_cloudfront_private_s3/images/s3-static-website.png)



# [aws/wordpress_fargate](aws/wordpress_fargate)
# Wordpress on Fargate

This terraform example demonstrates how to run a scalable wordpress site. In this exmaple, we have tried to use serverless technologies as much as possible. Hence, we chose to run the site on fargate and are using Aurora serverless as DB.

Read more about this on the blog [Terraform Recipe for WordPress on Fargate](https://futurice.com/blog/terraform-recipe-wordpress-fargate)

## AWS Services

We used the below AWS services in our example. The main motivation behind the selection of services is that we select as many serverless components as possible.

- Fargate - for computing
- Aurora Serverless - for database
- EFS (Elastic File System) - for persistent data storage
- Cloudfront - CDN

## Terraform setup

## Initialize terraform environment

```
terraform init -backend-config="bucket=<BUCKET_NAME>" -backend-config="profile=<AWS_PROFILE>" -backend-config="region=<AWS_REGION>"
```

### Create environment

```
  AWS_SDK_LOAD_CONFIG=1 \
  TF_VAR_site_domain=<PUBLIC_DOMAIN> \
  TF_VAR_public_alb_domain=<INTERNAL_DOMAIN_FOR_ALB> \
  TF_VAR_db_master_username=<DB_MASTER_USERNAME> \
  TF_VAR_db_master_password="<DB_MASTER_PASSWORD>" \
  AWS_PROFILE=<AWS_PROFILE> \
  AWS_DEFAULT_REGION=<AWS_REGION> \
  terraform apply
```

### Tear down

```
  AWS_SDK_LOAD_CONFIG=1 \
  TF_VAR_site_domain=<PUBLIC_DOMAIN> \
  TF_VAR_public_alb_domain=<INTERNAL_DOMAIN_FOR_ALB> \
  TF_VAR_db_master_username=<DB_MASTER_USERNAME> \
  TF_VAR_db_master_password="<DB_MASTER_PASSWORD>" \
  AWS_PROFILE=<AWS_PROFILE> \
  AWS_DEFAULT_REGION=<AWS_REGION> \
  terraform destroy
```

p.s. Instead of environment variables, you can obviously use .tfvar files for assigning values to terraform variables.



# [azure](azure)
# Azure Examples


# [azure/azure_linux_docker_app_service](azure/azure_linux_docker_app_service)
# azure_linux_docker_app_service

This terraform example demonstrates how to create a container based Linux App Service with secret management and monitoring.

## Features

- [Managed identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) for authentication instead of credentials
- [Key vault references](https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references) for accessing secrets from App Service
- Email alerts for errors and failed availability checks
- Random suffix for resources requiring globally unique name

## Azure services

![Architecture](azure/azure_linux_docker_app_service/images/architecture.png)

### [Azure Container Registry](https://azure.microsoft.com/en-us/services/)

For storing container images

- App Service pulls the image from the registry during deployment
- Authentication using managed identity

### [Key Vault](https://azure.microsoft.com/en-us/services/key-vault/)

For storing and accessing secrets

- Access management using access policies

### App Service plan & [App Service](https://azure.microsoft.com/en-us/services/app-service/)

For hosting the application. App Service is created into the plan. If you have multiple App Services, it is possible to share the same plan among them.

- The application's docker image is deployed from the container registry
- Managed identity for accessing the Key Vault & Container registry
- Deployment slot for high availability deploys
- App service has a lot of settings that can be configured. See all of them [here](https://github.com/projectkudu/kudu/wiki/Configurable-settings).

### [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)

User for monitoring, metrics, logs and alerts.

- The application should use Application Insights library (e.g. for [Node.js](https://www.npmjs.com/package/applicationinsights)) to instrument the application and integrate it with App Insights
- Includes availability checks from multiple locations
- Email alert for:
  - Failed availability checks
  - Responses with 5xx response code
  - Failed dependencies (e.g. database query or HTTP request fails)

## Example usage

Prerequisites

- Azure account and a service principal
- Resource group
- Terraform [Azure Provider](https://www.terraform.io/docs/providers/azurerm/) set up

```tf
module "my_app" {
  # Required
  resource_group_name = "my-resource-group"
  alert_email_address = "example@example.com"

  # Optional (with their default values)
  name_prefix            = "azure-app-example--"
  app_service_name      = "appservice"
  app_insights_app_type = "other"
  app_service_plan_tier = "PremiumV2"
  app_service_plan_size = "P1v2"
}
```

We can create rest of the resources with `terraform apply`.

An example of a Node.js application can be found in `./example-app` directory.

## Building an image and deploying to the App Service

- [Using Github actions](https://docs.microsoft.com/en-us/azure/app-service/deploy-container-github-action)
- [Using Azure DevOps pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/deploy/azure-rm-web-app-containers?view=azure-devops)

## Inputs

| Name                  | Description                                                                                                         |  Type  |         Default         | Required |
| --------------------- | ------------------------------------------------------------------------------------------------------------------- | :----: | :---------------------: | :------: |
| resource_group_name   | Name of the resource group where the resources are deployed                                                         | string |                         |   yes    |
| alert_email_address   | Email address where alerts are sent                                                                                 | string |                         |   yes    |
| name_prefix           | Name prefix to use for objects that need to be created (only lowercase alphanumeric characters and hyphens allowed) | string | `"azure-app-example--"` |    no    |
| app_service_name      | Name of the app service to be created. Must be globally unique                                                      | string |     `"appservice"`      |    no    |
| app_insights_app_type | Application insights application type                                                                               | string |        `"other"`        |    no    |
| app_service_plan_tier | App service plan tier                                                                                               | string |      `"PremiumV2"`      |    no    |
| app_service_plan_size | App service plan size                                                                                               | string |        `"P1v2"`         |    no    |



# [azure/layers](azure/layers)
# Terraform Azure Layers example

Azure resources may take a long time to create. Sometimes Terraform fails to spot that some resource actually requires another resourc


# [azure/layers](azure/layers)
e that has not been fully created yet. Layers help to ensure that all prerequisite resources for later ones are created before them.

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



# [generic](generic)
# Generic Examles


# [generic/docker_compose_host](generic/docker_compose_host)
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



# [google_cloud](google_cloud)
# Google Cloud Platform Examples


# [google_cloud/camunda-secure](google_cloud/camunda-secure)
## Provisioning Camunda on Cloud Run + Cloud SQL, using Terraform and Cloud Build

Terraform receipe for running Camunda BPMN workflow engine serverlessly on Cloud Run, using Cloud SQL as the backing store. Custom image building offloaded to Cloud Build. Private container image hosting in Google Container Engine.

Customize the base image in the main.tf locals.

Read more on the blog
- [Provisioning Serverless Camunda on Cloud Run](https://www.futurice.com/blog/serverless-camunda-terraform-recipe-using-cloud-run-and-cloud-sql) 
- [Call external services with at-least-once delevery](https://www.futurice.com/blog/at-least-once-delivery-for-serverless-camunda-workflow-automation)


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



# [google_cloud/camunda](google_cloud/camunda)
## Provisioning Camunda on Cloud Run + Cloud SQL, using Terraform and Cloud Build

Terraform receipe for running Camunda BPMN workflow engine serverlessly on Cloud Run, using Cloud SQL as the backing store. Custom image building offloaded to Cloud Build. Private container image hosting in Google Container Engine.

Customize the base image in the main.tf locals.

Read more on the blog
- [Provisioning Serverless Camunda on Cloud Run](https://www.futurice.com/blog/serverless-camunda-terraform-recipe-using-cloud-run-and-cloud-sql) 
- [Call external services with at-least-once delevery](https://www.futurice.com/blog/at-least-once-delivery-for-serverless-camunda-workflow-automation)


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



# [google_cloud/CQRS_bigquery_memorystore](google_cloud/CQRS_bigquery_memorystore)
## CQRS Bigquery Memorystore Timeseries Analytics with Self Testing Example

Read the blog [Exporting Bigquery results to memorystore](https://www.futurice.com/blog/bigquery-to-memorystore)

    # Bigquery #Memorystore #Cloud Functions #Cloud Scheduler #Pubsub #Cloud Storage

### Getting started

    export GOOGLE_CREDENTIALS=<PATH TO SERVICE ACCOUNT JSON CREDS>
    gcloud auth activate-service-account --key-file $GOOGLE_CREDENTIALS
    terraform init

Note you need to switch on the App Engine API (dependancy of Cloud Scheduler), choose wisely, this is irreversable. The region CANNOT be changed.


### Tips

Shut down memorystore

    terraform destroy -target module.memorystore.google_redis_instance.cache






# [google_cloud/minecraft](google_cloud/minecraft)
# Economical Minecraft server

A safe Minecraft server that won't break the bank. Game data is preserved across sessions. Server is hosted on a permenant IP address. You need to start the VM each session, but it will shutdown within 24 hours if you forget to turn it off. Process is run in a sandboxed VM, so any server exploits cannot do any serious damage.

We are experimenting with providing support through a [google doc](https://docs.google.com/document/d/1TXyzHKqoKMS-jY9FSMrYNLEGathqSG8YuHdj0Z9GP34).

Help us make this simple for others to use by asking for help.

Launch blog can be found [here](https://www.futurice.com/blog/friends-and-family-minecraft-server-terraform-recipe) 

Features
- Runs [itzg/minecraft-server](https://hub.docker.com/r/itzg/minecraft-server/) Docker image
- Preemtible VM (cheapest), shuts down automatically within 24h if you forget to stop the VM
- Reserves a stable public IP, so the minecraft clients do not need to be reconfigured
- Reserves the disk, so game data is remembered across sessions
- Restricted service account, VM has no ability to consume GCP resources beyond its instance and disk
- 2$ per month
  - Reserved IP address costs: $1.46 per month
  - Reserved 10Gb disk costs: $0.40
  - VM cost: $0.01 per hour, max session cost $0.24




# [google_cloud/oathkeeper](google_cloud/oathkeeper)
I was hoping to add an identity aware proxy to a Google Cloud Run endpoint using oathkeeper.
However, as of 2020/05/02 there is not easy way to fetch a token from the metadata server
and add it to an upstream header, required to make an authenticated call to a protected Cloud Run endpoint


# [google_cloud/openresty-beyondcorp](google_cloud/openresty-beyondcorp)
# Swiss Army Identity Aware Proxy

Very fast Serverless OpenResty based proxy that can wrap upstream binaries with a login. Furthermore, we have examples of 
- Local development environment
- Slack/Zapier intergration.
- A Write Ahead Log
- Google Secret Manager intergration

Read more on the [OpenResty: a Swiss Army Proxy for Serverless; WAL, Slack, Zapier and Auth](https://futurice.com/blog/openresty-a-swiss-army-proxy-for-serverless) blog.

An earlier version is linked to in the [Minimalist BeyondCorp style Identity Aware Proxy for Cloud Run](https://futurice.com/blog/identity-aware-proxy-for-google-cloud-run) blog that is just the login part.

## OpenResty and Cloud Run

Build on top of OpenResty, hosted on Cloud Run (and excellent match)

## Extensions Fast Response using a Write Ahead Log

If upstream is slow (e.g. scaling up), you can redirect to a WAL. Latency is the time to store the message. 
A different location plays back the WAL with retries so you can be sure the request is eventially handled.

## Extensions Securing a Slack Intergration

Intergration with Slack
Reads a secret from Google secrets manager and verifies the signature HMAC

## Extensions Securing a Zapier Intergration

Zapier can be protected with an Oauth account

## Local testing with docker-compose

Generate a local service account key in .secret

`gcloud iam service-accounts keys create .secret/sa.json --iam-account=openresty@larkworthy-tester.iam.gserviceaccount.com`

run this script to get a setup that reloads on CTRL + C

`/bin/bash test/dev.sh`

The use of bash to start the script gives it an easier name to find to kill

killall "bash"

# Get prod tokens

    https://openresty-flxotk3pnq-ew.a.run.app/login?token=true

# Test WAL verification

    curl -X POST -d "{}" http://localhost:8080/wal-playback/

# Test token validation

    curl http://localhost:8080/httptokeninfo?id_token=foo
    curl http://localhost:8080/httptokeninfo?access_token=foo


# Test slack

    curl http://localhost:8080/slack/command


