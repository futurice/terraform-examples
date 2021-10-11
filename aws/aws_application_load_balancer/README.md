# aws_application_load_balancer
  
These templates implements a application load balancer, and associated necessary steps require for loadbalancing. This includes:

- Security groups for instances and loadbalancer
- Target grout attachment for instances
- Template for launching instances
- Load balancer

## Step 1: Provider.tf
First write down provider template, enter region you want to provision load-balancer and provide access key and secret key

```tf
provider "aws" {
  region     = "Enter_Region"
  access_key = "Enter_Your_Access_Key"
  secret_key = "Enter_Secret_Key"
}
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
